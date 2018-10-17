# -*- cod# -*- coding: utf-8 -*-s

from random import *

# La classe carré représente un cellule de la grille non peuplée
class Carre:
    def __init__(self, tailleCellule, etat):

        self.etat = etat
        self.tailleCellule = tailleCellule
        self.setEtat(etat)

    def setEtat (self, etat):
        self.etat = etat;
        if (self.etat == "mur"):
            self.couleur = 'black'
        elif(self.etat == "eau"):
            self.couleur = 'blue'
        else: # donc cellule vide
            self.couleur = 'white'

    def afficher (self, canvas, x, y):
        x0 = x*self.tailleCellule
        y0 = y*self.tailleCellule
        x1 = (x*self.tailleCellule)+self.tailleCellule
        y1 = (y*self.tailleCellule)+self.tailleCellule

        # Taille bordure cellule
        if (self.tailleCellule > 2):
            bordure = 1
        else:
            bordure = 0

        canvas.create_rectangle(x0, y0, x1, y1, fill=self.couleur, width=bordure)

#END Carre


# La classe CarrePopulation représente une cellule peuplée
class CarrePopulation (Carre):
    def __init__(self, tailleCellule, etat, moyenneAge):

        self.tailleCellule = tailleCellule
        self.moyenneAge = moyenneAge
        self.setEtat(etat)

    def setEtat (self, etat):
        self.etat = etat
        if (self.etat == "sain"):
            self.couleur = 'green'
        elif (self.etat == "infecte"):
            self.couleur = 'red'
        else: # donc cellule inconnue
            self.couleur = 'yellow'

    # gerererAgeMoyen renvoie un age moyen calculé à partir du nombre de personnes
    # représentées par une cellule et les statistiques trouvée sur le site :
    # https://fr.statista.com/statistiques/472349/repartition-population-groupe-dage-france/
    @staticmethod
    def genenerAgeMoyen(nbPers):
        ageMoy = 0
        for i in range (0, nbPers):
            nbAlea = uniform(0, 100)
            if (nbAlea < 18.2):
                age = randint(0,14)
            elif(nbAlea < 18.2 + 6.2):
                age = randint(15,19)
            elif(nbAlea < 18.2 + 6.2 + 5.6):
                age = randint(20,24)
            elif(nbAlea < 18.2 + 6.2 + 5.6 + 5.8):
                age = randint(25,29)
            elif(nbAlea < 18.2 + 6.2 + 5.6 + 5.8 + 6):
                age = randint(30,34)
            elif(nbAlea < 18.2 + 6.2 + 5.6 + 5.8 + 6 + 6.3):
                age = randint(35,39)
            elif(nbAlea < 18.2 + 6.2 + 5.6 + 5.8 + 6 + 6.3 + 6.3):
                age = randint(40,44)
            elif(nbAlea < 18.2 + 6.2 + 5.6 + 5.8 + 6 + 6.3 + 6.3 + 6.8):
                age = randint(45,49)
            elif(nbAlea < 18.2 + 6.2 + 5.6 + 5.8 + 6 + 6.3 + 6.3 + 6.8 + 6.7):
                age = randint(50,54)
            elif(nbAlea < 18.2 + 6.2 + 5.6 + 5.8 + 6 + 6.3 + 6.3 + 6.8 + 6.7 + 6.4):
                age = randint(55,59)
            elif(nbAlea < 18.2 + 6.2 + 5.6 + 5.8 + 6 + 6.3 + 6.3 + 6.8 + 6.7 + 6.4 + 6.1):
                age = randint(60,64)
            elif(nbAlea < 18.2 + 6.2 + 5.6 + 5.8 + 6 + 6.3 + 6.3 + 6.8 + 6.7 + 6.4 + 6.1 + 5.9):
                age = randint(65,69)
            elif(nbAlea < 18.2 + 6.2 + 5.6 + 5.8 + 6 + 6.3 + 6.3 + 6.8 + 6.7 + 6.4 + 6.1 + 5.9 + 4.5):
                age = randint(70,74)
            elif(nbAlea < 18.2 + 6.2 + 5.6 + 5.8 + 6 + 6.3 + 6.3 + 6.8 + 6.7 + 6.4 + 6.1 + 5.9 + 4.5 + 9.2):
                age = randint(75,100)

            ageMoy += age

        ageMoy = round(ageMoy/nbPers)
        return ageMoy