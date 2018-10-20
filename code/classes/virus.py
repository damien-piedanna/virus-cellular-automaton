# -*- cod# -*- coding: utf-8 -*-
############################################################################
#
# Ce fichier contient les classes relatives aux virus propagés sur la carte
#
############################################################################


# La classe Virus représente le virus à propager
class Virus:
    def __init__(self, label):
        self.label = label
        if (self.label == "Peste noire"):
            self.tauxReproduction = 15
            self.tauxAge15 = 0.7
            self.tauxAge50 = 0.6
            self.tauxAge70 = 0.7
            self.tauxAge90 = 0.8
            self.tauxAge100 = 0.9

        elif (self.label == "Rougeole"):
            self.tauxReproduction = 12
            self.tauxAge15 = 0.6
            self.tauxAge50 = 0.5
            self.tauxAge70 = 0.6
            self.tauxAge90 = 0.7
            self.tauxAge100 = 0.8

        elif (self.label == "Coqueluche"):
            self.tauxReproduction = 10
            self.tauxAge15 = 0.6
            self.tauxAge50 = 0.5
            self.tauxAge70 = 0.5
            self.tauxAge90 = 0.6
            self.tauxAge100 = 0.7

        elif (self.label == "Diphtérie"):
            self.tauxReproduction = 8
            self.tauxAge15 = 0.6
            self.tauxAge50 = 0.4
            self.tauxAge70 = 0.5
            self.tauxAge90 = 0.6
            self.tauxAge100 = 0.7

        elif (self.label == "Variole"):
            self.tauxReproduction = 6
            self.tauxAge15 = 0.6
            self.tauxAge50 = 0.4
            self.tauxAge70 = 0.4
            self.tauxAge90 = 0.5
            self.tauxAge100 = 0.6

        elif (self.label == "Poliomyélite"):
            self.tauxReproduction = 4
            self.tauxAge15 = 0.6
            self.tauxAge50 = 0.3
            self.tauxAge70 = 0.2
            self.tauxAge90 = 0.1
            self.tauxAge100 = 0.2

        elif (self.label == "Grippe"):
            self.tauxReproduction = 2
            self.tauxAge15 = 0.5
            self.tauxAge50 = 0.3 
            self.tauxAge70 = 0.4
            self.tauxAge90 = 0.5
            self.tauxAge100 = 0.6

        else: # Virus inconnu
            self.tauxReproduction = 5
            self.tauxAge15 = 0.5
            self.tauxAge50 = 0.5
            self.tauxAge70 = 0.5
            self.tauxAge90 = 0.5
            self.tauxAge100 = 0.5