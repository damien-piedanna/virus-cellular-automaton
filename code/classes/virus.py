# -*- cod# -*- coding: utf-8 -*-

# La classe Virus représente le virus à propager
class Virus:
    def __init__(self, label):
        self.label = label
        if (self.label == "Peste noire"):
            self.tauxReproduction = 12.5
        else: # Virus inconnu
            self.tauxReproduction = 5