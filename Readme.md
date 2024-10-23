# TP Transmission Réception Verilog

## Table des Matières
1. [Introduction](#introduction)
2. [Objectifs](#objectifs)
3. [Matériel Utilisé](#matériel-utilisé)
4. [Architecture du Système](#architecture-du-système)
5. [Tests et Validation](#tests-et-validation)
6. [Résultats](#résultats)

## Introduction
Ce projet est réalisé dans le cadre du module "Instrumentation et interfaçage des systèmes embarqués" de mon Master 2 à l'université Paris-Saclay.

## Objectifs
L'objectif est d'implémenter la norme V24 de la communication UART en Verilog et de développer un bloc IP optimisé en taille, destiné à devenir un périphérique MMIO pouvant être intégré dans un SoC.

## Matériel Utilisé
Actuellement, j'utilise une carte de développement SiSpeed Tang Nano 9K basée sur un FPGA Gowin GW1NR-9LV C5/6. Cependant, le but est de rendre le bloc matériel agnostique et synthétisable sur n'importe quel FPGA.

## Architecture du Système

### Module UART TX (uart_tx) :
- Implémente la transmission UART.
- Utilise une FSM (Machine à États Finis) pour gérer les transitions entre les états : repos, bit de démarrage, bits de données, bit d'arrêt, terminé.
- Le signal RTS est activé lorsque l'émetteur est prêt à envoyer, et désactivé à la fin de la transmission.
- L'entrée CTS garantit que l'émetteur n'envoie des données que lorsque le récepteur est prêt.

### Module UART RX (uart_rx) :
- Implémente la réception UART.
- Utilise une FSM pour gérer la détection du bit de démarrage, la réception des bits de données, le bit d'arrêt, et le stockage des données reçues.
- Le signal CTS est activé lorsque le récepteur est prêt à accepter les données, et désactivé à la fin de la réception.
- RTS est une entrée provenant de l'émetteur, et le récepteur échantillonne les bits entrants.

### Module Principal (uart_top) :
- Combine les modules de transmission et de réception.
- Connecte le signal `tx` de l'émetteur à l'entrée `rx` du récepteur, simulant une boucle de retour (loopback).
- Le signal `tx_done` est activé à la fin de la transmission, et `rx_done` est activé à la fin de la réception.

## Tests et Validation
Pas encore de tests effectués.

## Résultats
Aucun résultat disponible pour l'instant.
