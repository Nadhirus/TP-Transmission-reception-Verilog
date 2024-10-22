# TP Transmission Réception Verilog

## Table des Matières
1. [Introduction](#introduction)
2. [Objectifs](#objectifs)
3. [Prérequis](#prérequis)
4. [Matériel Utilisé](#matériel-utilisé)
5. [Description du Projet](#description-du-projet)
6. [Architecture du Système](#architecture-du-système)
7. [Instructions de Compilation](#instructions-de-compilation)
8. [Tests et Validation](#tests-et-validation)
9. [Résultats](#résultats)
10. [Conclusion](#conclusion)
11. [Références](#références)

## Introduction
Fournir une brève introduction au projet et son contexte.

## Objectifs
Lister les objectifs principaux du TP.

## Prérequis
Décrire les connaissances et compétences nécessaires pour réaliser ce TP.

## Matériel Utilisé
Énumérer le matériel et les logiciels utilisés dans ce projet.

## Description du Projet
Donner une description détaillée du projet, y compris les fonctionnalités et les spécifications.

## Architecture du Système
Expliquer l'architecture du système, avec des diagrammes si nécessaire.

## Instructions de Compilation
Fournir des instructions étape par étape pour compiler le code Verilog.

## Tests et Validation
Décrire les tests effectués pour valider le fonctionnement du système.

## Résultats
Présenter les résultats obtenus, avec des graphiques ou des tableaux si nécessaire.

## Conclusion
Fournir une conclusion sur les travaux réalisés et les apprentissages.

## Références

Lister les références et ressources utilisées pour ce projet.


# Module UART TX (uart_tx) :

- Implémente le processus de transmission UART.
- Utilise une FSM (Machine à États Finis) pour gérer les transitions d'état (repos, bit de démarrage, bits de données, bit d'arrêt, terminé).
- RTS est activé lorsque l'émetteur est prêt à envoyer, et désactivé à la fin de la transmission.
- L'entrée CTS garantit que l'émetteur n'envoie les données que lorsque le récepteur est prêt.

# Module UART RX (uart_rx) :

- Implémente le processus de réception UART.
- Utilise une FSM pour gérer la détection du bit de démarrage, la réception des bits de données, le bit d'arrêt, et le stockage des données reçues.
- CTS est activé lorsque le récepteur est prêt à accepter les données, et désactivé à la fin de la réception.
- RTS est une entrée provenant de l'émetteur, et le récepteur échantillonne les bits entrants.

# Module Principal (uart_top) :

- Combine les modules de transmission et de réception.
- Connecte le signal `tx` de l'émetteur à l'entrée `rx` du récepteur, simulant une boucle de retour (loopback).
- Le signal `tx_done` est activé lorsque la transmission est terminée, et le signal `rx_done` est activé lorsque la réception est terminée.
