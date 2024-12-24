#include <reg592.h> /* registres spécifiques au 592 */
#include <stdio.h>
#include "libtp2.h"

sbit P1_7_Tx = 0x97;
sbit P1_6_Rx = 0x96;

sbit P1_7_RTS = 0x95; // RTS signal pin
sbit P1_6_CTS = 0x94; // CTS signal pin

xdata unsigned int barreg _at_ 0xfd00;

/****************************************************/
/*  Déclaration des variables et tableaux           */
/****************************************************/

code int TAB[10] = {0x001, 0x003, 0x007, 0x00f, 0x01f, 0x03f, 0x07f, 0x0ff, 0x1ff, 0x3ff};
bit FLAG = 0;
unsigned int j;

bit transmit = 0;
bit Tx = 1, Rx = 0;
bit RTS = 1, CTS = 1; // Initialize RTS and CTS flags

char etat_Tx = 0;
unsigned char logic_count_Tx;
char nb_bits;
unsigned char Var_Tx; /* Tampon de transmission */

unsigned char logic_count_Rx;
char nb_bitR, etat_Rx = 0;
bit received_data = 0;
unsigned char Var_Rx, Var_loc;

unsigned char touche;
char buff[8];

/****************************************************/
/*  Automates de Transmission et Reception          */
/****************************************************/

bit tempo2()
{
	static unsigned int compt = 0;
	compt++;

	if (compt == 10000)
	{
		compt = 0;
		return 1;
	}
	else
		return 0;
}

void Motif(void)
{
	FLAG = tempo2();
	if (FLAG == 1)
	{
		barreg = TAB[j];
		j = (j + 1) % 10;
	}
}

/*****************************************/
/*  Interruption du timer0		 */
/*****************************************/

void timer0() interrupt 1
{
	P1_7_Tx = Tx;
	Rx = P1_6_Rx;
	P1_7_RTS = RTS; // Set RTS to the corresponding pin
	CTS = P1_6_CTS; // Set CTS from the corresponding pin
	emission();
	reception();
}

/***************************************/
/* Fonctions d'émission et réception   */
/***************************************/

void emission()
{
	switch (etat_Tx)
	{
	case 0:
		Tx = 1;
		if ((transmit == 1) && (CTS == 0)) // Proceed only if CTS is asserted by receiver (inverted logic)
		{
			etat_Tx = 1;
		}
		break;
	case 1:
		Tx = 0;
		nb_bits = 0;
		logic_count_Tx = 0;
		etat_Tx = 2;
		break;
	case 2:
		if ((logic_count_Tx == 12) && (nb_bits == 9))
		{
			etat_Tx = 4;
		}
		if ((logic_count_Tx == 12) && (nb_bits != 9))
		{
			etat_Tx = 3;
		}
		logic_count_Tx++;
		break;
	case 3:
		logic_count_Tx = 0;
		if (nb_bits < 8)
		{
			Tx = Var_Tx & 0x01;
			Var_Tx = Var_Tx >> 1;
		}
		else
		{
			Tx = 1;
		}
		nb_bits++;
		etat_Tx = 2;
		break;
	case 4:
		transmit = 0;
		RTS = 1; // desactiver RTS a la fin de transmission (inverted logic)
		etat_Tx = 0;
		break;
	}
}

void reception()
{
	switch (etat_Rx)
	{
	case 0:
		logic_count_Rx = 0;
		if ((Rx == 0) && (CTS == 0)) // Proceed only if RTS is asserted by sender 
		//(we're verifying CTS because w're using crossed wire as part of the stand v24) (inverted logic)
		{
			RTS = 0;
			etat_Rx = 1;
		}
		break;
	case 1:
		if (logic_count_Rx == 5)
		{
			etat_Rx = 2;
		}
		logic_count_Rx++;
		break;
	case 2:
		logic_count_Rx = 0;
		nb_bitR = 0;
		etat_Rx = 3;
		break;
	case 3:
		if ((logic_count_Rx == 12) && (nb_bitR == 8))
		{
			etat_Rx = 5;
		}
		if ((logic_count_Rx == 12) && (nb_bitR != 8))
		{
			etat_Rx = 4;
		}
		logic_count_Rx++;
		break;
	case 4:
		nb_bitR++;
		logic_count_Rx = 0;
		Var_loc = Var_loc >> 1;
		if (Rx == 1)
		{
			Var_loc = Var_loc | (0x80);
		}
		etat_Rx = 3;
		break;
	case 5:
		if (received_data == 0)
		{
			Var_Rx = Var_loc;
			received_data = 1;
		}
		RTS = 1;
		etat_Rx = 0;
		break;
	}
}

/***************************************/
/* Programme principal                 */
/***************************************/

void main(void)
{
	TH0 = TL0 = 0;
	TMOD = TMOD | 2; /* timer 0 en autoload 8 bits */
	TR0 = 1;		 /* lance le timer 0*/
	ET0 = 1;		 /* autorise l'IT du timer 0 */
	EA = 1;			 /* autorise les ITs  */

	transmit = 0;
	received_data = 0;
	RTS = 1;
	CTS = 0; // Initialize RTS/CTS

	init_lcd();

	while (1)
	{
		touche = detect_touche();
		if (transmit == 0)
		{
			if (touche != (char)0xff)
			{
				Var_Tx = decode_touche(touche);
				transmit = 1;
				RTS = 0; // activer RTS au debut de transmission (inverted logic)
				printf("touche : %u\n", (unsigned int)Var_Tx);
			}
		}

		if (received_data == 1)
		{
			sprintf(buff, "%u\n", (unsigned int)Var_Rx);
			LCD_goto(0, 0);
			print_lcd(buff);
			printf("received %u\n", (unsigned int)Var_Rx);
			received_data = 0;
		}
		Motif();
	}
}
