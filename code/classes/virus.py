# -*- cod# -*- coding: utf-8 -*-

# La classe Virus représente le virus à propager
class Virus:
    def __init__(self, label):
        self.label = label
        if (self.label == "Peste noire"):
            self.tauxReproduction = 15

        elif (self.label == "Rougeole"):
            self.tauxReproduction = 12

        elif (self.label == "Coqueluche"):
            self.tauxReproduction = 10

        elif (self.label == "Rougeole"):
            self.tauxReproduction = 8

        elif (self.label == "Variole"):
            self.tauxReproduction = 6

        elif (self.label == "VIH"):
            self.tauxReproduction = 4

        elif (self.label == "Grippe"):
            self.tauxReproduction = 2  

        else: # Virus inconnu
            self.tauxReproduction = 5

#END Virus
