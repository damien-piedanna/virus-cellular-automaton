# -*- cod# -*- coding: utf-8 -*-

#https://fr.statista.com/statistiques/472349/repartition-population-groupe-dage-france/
#https://www.insee.fr/fr/statistiques/1892088?sommaire=1912926

from tkinter import *
from random import *
from math import sqrt
import time
import threading
import copy

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

#END Carre_population



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


# La classe zone urbaine représente des regroupements de population sur la grille
class ZoneUrbaine:
    def __init__(self, grille, genre):
        self.genre = genre # (Metropole, Ville, ZonePeuplee, Village)
        self.posX = randint(0, grille.nbCelluleHauteur)
        self.posY = randint(0, grille.nbCelluleLargeur)

        if (self.genre == "Metropole"): # Rayon entre 1/3 et 1/2 de la taille maximale de la grille
            if (grille.nbCelluleHauteur < grille.nbCelluleLargeur):
                self.rayon = randint(int(grille.nbCelluleHauteur/3), int(grille.nbCelluleHauteur/2))
            else:
                self.rayon = randint(int(grille.nbCelluleLargeur/3), int(grille.nbCelluleLargeur/2))
        elif (self.genre == "Ville"): # Rayon entre 1/8 et 1/4 de la taille maximale de la grille
            if (grille.nbCelluleHauteur < grille.nbCelluleLargeur):
                self.rayon = randint(int(grille.nbCelluleHauteur/8), int(grille.nbCelluleHauteur/4))
            else:
                self.rayon = randint(int(grille.nbCelluleLargeur/8), int(grille.nbCelluleLargeur/4))
        elif (self.genre == "Village"): # Rayon entre 1/8 et 1/2 de la taille maximale de la grille
            if (grille.nbCelluleHauteur < grille.nbCelluleLargeur):
                self.rayon = randint(int(grille.nbCelluleHauteur/16), int(grille.nbCelluleHauteur/10))
            else:
                self.rayon = randint(int(grille.nbCelluleLargeur/16), int(grille.nbCelluleLargeur/10))
        elif (self.genre == "ZonePeuplee"): # Rayon entre 1/8 et 1/2 de la taille maximale de la grille
            if (grille.nbCelluleHauteur < grille.nbCelluleLargeur):
                self.rayon = randint(int(grille.nbCelluleHauteur/8), int(grille.nbCelluleHauteur/2))
            else:
                self.rayon = randint(int(grille.nbCelluleLargeur/8), int(grille.nbCelluleLargeur/2))
        else: #Zone inconnue
            self.rayon = 1
        # Rayon < 1 interdit
        if (self.rayon == 0):
            self.rayon = 1

    # Renvoie la distance du point (posX, posY) au centre de la zone courante
    def distanceAuCentre(self, posX, posY):
        # Distance de A à B = racine((Xb-Xa)^2 + (Yb-Ya)^2)
        # On prend la valeur absolue car l'orientation dans le repère ne nous interesse pas
        distance = int(abs(sqrt((posX-self.posX)*(posX-self.posX) + (posY-self.posY)*(posY-self.posY))))
        return distance

    # Renvoie True si le point (posX, posY) appartient à la zone courante
    def contient(self, posX, posY):
        if (self.distanceAuCentre(posX, posY) <= self.rayon):
            return True;
        return False;

    # Renvoie True si la zone courante chevauche la zone zoneUrbaine
    def chevauche(self, zoneUrbaine):
        distanceZones = zoneUrbaine.distanceAuCentre(self.posX, self.posY)
        if (distanceZones < self.rayon + zoneUrbaine.rayon):
            return True
        return False


# END ZoneUrbaine


# La classe Deplacement représente un moyen de transport allant d'un point à un autre
class Deplacement:
    def __init__(self, etat, posX1, posY1, posX2, posY2, tailleCellule):
        self.setEtat(etat)
        self.posX1 = posX1
        self.posY1 = posY1
        self.posX2 = posX2
        self.posY2 = posY2
        self.tailleCellule = tailleCellule

    def setEtat (self, etat):
        self.etat = etat
        if (self.etat == "pont"):
            self.couleur = 'lime'
        elif (self.etat == "route"):
            self.couleur = 'brown'
        elif (self.etat == "voieFerree"):
            self.couleur = 'orange'
        elif (self.etat == "ligneAerienne"):
            self.couleur = 'pink'
        else: # donc cellule inconnue
            self.couleur = 'yellow'

    def afficher (self, canvas):
        x0 = self.posX1*self.tailleCellule + int(10/100 * self.tailleCellule)
        y0 = self.posY1*self.tailleCellule + int(10/100 * self.tailleCellule)
        x1 = (self.posX1*self.tailleCellule)+self.tailleCellule - int(10/100 * self.tailleCellule)
        y1 = (self.posY1*self.tailleCellule)+self.tailleCellule - int(10/100 * self.tailleCellule)
        canvas.create_oval(x0, y0, x1, y1, fill=self.couleur, width=0)

        x0 = self.posX2*self.tailleCellule + int(10/100 * self.tailleCellule)
        y0 = self.posY2*self.tailleCellule + int(10/100 * self.tailleCellule)
        x1 = (self.posX2*self.tailleCellule)+self.tailleCellule - int(10/100 * self.tailleCellule)
        y1 = (self.posY2*self.tailleCellule)+self.tailleCellule - int(10/100 * self.tailleCellule)
        canvas.create_oval(x0, y0, x1, y1, fill=self.couleur, width=0)
        
        x0 = self.posX1*self.tailleCellule + int(self.tailleCellule/2)
        y0 = self.posY1*self.tailleCellule + int(self.tailleCellule/2)
        x1 = self.posX2*self.tailleCellule + int(self.tailleCellule/2)
        y1 = self.posY2*self.tailleCellule + int(self.tailleCellule/2)
        
        epaisseur = int(20/100 * self.tailleCellule)
        if (self.etat == "pont"):
            epaisseur = self.tailleCellule - int(20/100 * self.tailleCellule)

        canvas.create_line(x0, y0, x1, y1, fill=self.couleur, width=epaisseur)

# END Deplacement

class Position:
    def __init__(self, posX, posY):
        self.posX = posX
        self.posY = posY

# END Position


# Classe Fleuve représente un fleuve
class Fleuve:
    def __init__(self, grille):
        print("Création d'un fleuve...")
        self.parcours = []
        # Largueur du fleuve maximum 1/10 de la taille max de la grille
        # Si largeur est paire, le fleuve est représenté avec une largeur de largeur+1
        if (grille.nbCelluleHauteur < grille.nbCelluleLargeur):
            self.largeur = randint(3,int(grille.nbCelluleHauteur/10))
        else:
            self.largeur = randint(3,int(grille.nbCelluleLargeur/10))

        # 1 chance sur 2 pour que le fleuve parte du haut ou de la gauche de la grille
        if(randint(0,1)):
            self.departAGauche = True
            posX = 0 # Départ à gauche
            posY = randint(5, grille.nbCelluleHauteur-5) # Le fleuve ne peut pas partir des autres bords
            # Tant que le fleuve n'atteind pas un bord
            while (posX < grille.nbCelluleLargeur and posY > 0 and posY < grille.nbCelluleHauteur):
                # On créer une nouvelle cellule du fleuve
                grille.matCarre[posY][posX] = Carre(grille.tailleCellule, "eau")
                self.parcours.append(Position(posX, posY))

                # On étend la largeur du fleuve
                for i in range (1,int(self.largeur/2)+1):
                    if (posY-i >= 0):
                        grille.matCarre[posY-i][posX] = Carre(grille.tailleCellule, "eau")
                    if (posY+i < grille.nbCelluleHauteur):
                        grille.matCarre[posY+i][posX] = Carre(grille.tailleCellule, "eau")

                # Position de la prochaine cellule du fleuve
                posX = posX+1
                posY = randint(posY-1, posY+1)
        else:
            self.departAGauche = False
            posY = 0 # Départ en haut
            posX = randint(5, grille.nbCelluleLargeur-5) # Le fleuve ne peut pas partir des autres bords
            # Tant que le fleuve n'atteind pas un bord
            while (posY < grille.nbCelluleHauteur and posX > 0 and posX < grille.nbCelluleLargeur):
                # On créer une nouvelle cellule du fleuve
                grille.matCarre[posY][posX] = Carre(grille.tailleCellule, "eau")
                self.parcours.append(Position(posX, posY))

                # On étend la largeur du fleuve
                for i in range (1,int(self.largeur/2)+1):
                    if (posX-i >= 0):
                        grille.matCarre[posY][posX-i] = Carre(grille.tailleCellule, "eau")
                    if (posX+i < grille.nbCelluleLargeur):
                        grille.matCarre[posY][posX+i] = Carre(grille.tailleCellule, "eau")

                # Position de la prochaine cellule du fleuve
                posX = randint(posX-1, posX+1)
                posY = posY+1
        print("Fleuve de largeur " + repr(self.largeur) + " généré.")

# END Fleuve


# La classe Grille représente la carte
class Grille:
    def __init__(self, fenetre, nbCelluleHauteur, nbCelluleLargeur, virus, nbPers):
        print("Génération de la grille...")

        # Initialisation des attributs de la grille
        self.nbCelluleHauteur = nbCelluleHauteur
        self.nbCelluleLargeur = nbCelluleLargeur
        self.virus = virus
        self.nbPers = nbPers
        self.nbInfecte = 0
        self.nbSain = 0

        hauteurEcranPx = fenetre.winfo_screenheight()
        largeurEcranPx = fenetre.winfo_screenwidth()
        self.tailleCellule = int((hauteurEcranPx-200)/nbCelluleHauteur)
        if (nbCelluleLargeur*self.tailleCellule > largeurEcranPx):
            self.tailleCellule = int(largeurEcranPx/nbCelluleLargeur)

        self.grille = Canvas(fenetre, width=self.tailleCellule*nbCelluleLargeur, height=self.tailleCellule*self.nbCelluleHauteur, background='white')

        self.matCarre = []

        self.deplacements = []

        # Affectation des actions de la souris
        self.grille.bind("<Button-1>", self.infecterManu)
        self.grille.bind("<Button-2>", self.propagerUneFois)
        self.grille.bind("<Button-3>", self.guerirManu)
        self.grille.pack()

        # Création des zones urbaines
        self.zonesUrbaines = self.genererZonesUrbaines()

        #Crée les carrés composant la grille et les range dans une matrice
        for y in range (0, nbCelluleHauteur):
            ligne = []
            for x in range (0, nbCelluleLargeur):
                estDansUneZoneUrbaine = False

                # Parcours de toutes les zones urbaines de la grille
                for i in range (0, len(self.zonesUrbaines)):
                    zoneUrbaine = self.zonesUrbaines[i]
                    if (zoneUrbaine.contient(x,y)):
                        if (zoneUrbaine.genre == "ZonePeuplee"):
                            if (randint(1,4) == 1): # 1 chance sur 4 qu'un carré soit peuplé dans une zone peuplée
                                ageMoy = CarrePopulation.genenerAgeMoyen(self.nbPers)
                                ligne.append(CarrePopulation(self.tailleCellule, "sain", ageMoy))
                                self.nbSain = self.nbSain + 1
                            else:
                                ligne.append(Carre(self.tailleCellule, "vide"))
                        else:
                            probaPop = (-75/zoneUrbaine.rayon)*zoneUrbaine.distanceAuCentre(x,y) + 100 # Calcul expliqué dans le fichier calculsZone.txt
                            if (randint(0,100) < probaPop): # Plus on est loin du centre moins la population est dense
                                ageMoy = CarrePopulation.genenerAgeMoyen(self.nbPers)
                                ligne.append(CarrePopulation(self.tailleCellule, "sain", ageMoy))
                                self.nbSain = self.nbSain + 1
                            else:
                                ligne.append(Carre(self.tailleCellule, "vide"))
                        estDansUneZoneUrbaine = True
                        break # Pas besoin de parcourir les autres zones car une cellule ne peut être que dans une seule zone

                if(not(estDansUneZoneUrbaine)):
                    if (randint(1,8) == 1): # 1 chance sur 8 qu'un carré soit peuplé si il est en dehors d'une zone urbaine
                        ageMoy = CarrePopulation.genenerAgeMoyen(self.nbPers)
                        ligne.append(CarrePopulation(self.tailleCellule, "sain", ageMoy))
                        self.nbSain = self.nbSain + 1
                    else:
                        ligne.append(Carre(self.tailleCellule, "vide"))

            self.matCarre.append(ligne)
        # Taille minimal pour générer un fleuve
        if(self.nbCelluleLargeur >= 30 and self.nbCelluleHauteur >= 30):
            self.fleuve = Fleuve(self)

        self.genererDeplacements()

        print("Grille générée !")

    # genererZonesUrbaines génère aléatoirement des zones urbaines dans la grille
    def genererZonesUrbaines(self):
        zonesUrbaines = []

        if(randint(1,6) == 1): # 1 chance sur 6 qu'il est une métropole
            metropole = ZoneUrbaine(self,"Metropole")
            zonesUrbaines.append(metropole)
        for i in range (0, randint(2,4)): # Entre 2 et 4 villes
            for j in range (0,10): # Créer une nouvelle zone tant qu'elle en chevauche une autre (10 essai max avant abandon)
                zone = ZoneUrbaine(self,"Ville")
                nbZonesChevauchees = 0
                for i in range (0, len(zonesUrbaines)):
                    if (zone.chevauche(zonesUrbaines [i])):
                        nbZonesChevauchees = nbZonesChevauchees + 1
                if (nbZonesChevauchees == 0):
                    zonesUrbaines.append(zone)
                    break
        for i in range (0, randint(5,10)): # Entre 5 et 10 villages
            for j in range (0,10): # Créer une nouvelle zone tant qu'elle en chevauche une autre (10 essai max avant abandon)
                zone = ZoneUrbaine(self,"Village")
                nbZonesChevauchees = 0
                for i in range (0, len(zonesUrbaines)):
                    if (zone.chevauche(zonesUrbaines [i])):
                        nbZonesChevauchees = nbZonesChevauchees + 1
                if (nbZonesChevauchees == 0):
                    zonesUrbaines.append(zone)
                    break
        for i in range (0, randint(0,2)): # Entre 0 et 2 zones peuplées
            for j in range (0,10): # Créer une nouvelle zone tant qu'elle en chevauche une autre (10 essai max avant abandon)
                zone = ZoneUrbaine(self,"ZonePeuplee")
                nbZonesChevauchees = 0
                for i in range (0, len(zonesUrbaines)):
                    if (zone.chevauche(zonesUrbaines [i])):
                        nbZonesChevauchees = nbZonesChevauchees + 1
                if (nbZonesChevauchees == 0):
                    zonesUrbaines.append(zone)
                    break


        print(repr(len(zonesUrbaines)) + " zones urbaines :")
        for i in range (0, len(zonesUrbaines)):
            print("La zone " + repr(i) + " est un(e) " + zonesUrbaines[i].genre + " de centre (" + repr(zonesUrbaines[i].posX) + "," + repr(zonesUrbaines[i].posY) + ") et de rayon " + repr(zonesUrbaines[i].rayon))

        return zonesUrbaines

    # Génère tous les déplacements de la grille
    def genererDeplacements(self):
        # Taille minimal pour générer un fleuve
        if(self.nbCelluleLargeur >= 30 and self.nbCelluleHauteur >= 30):
            # Création des ponts
            if (self.fleuve.departAGauche):
                i = 0
                while (i < len(self.fleuve.parcours)):
                    posX = self.fleuve.parcours[i].posX
                    posY = self.fleuve.parcours[i].posY
                    if(not(randint(0,10)) and posY+int(self.fleuve.largeur/2)+1 < self.nbCelluleHauteur and posY-int(self.fleuve.largeur/2)-1 > 0):
                        self.deplacements.append(Deplacement("pont", posX, posY+int(self.fleuve.largeur/2)+1, posX, posY-int(self.fleuve.largeur/2)-1, self.tailleCellule))
                        i += 5 # Ponts espacés de 4 cellules minimum
                    else:
                        i += 1
            else:
                i = 0
                while (i < len(self.fleuve.parcours)):
                    posX = self.fleuve.parcours[i].posX
                    posY = self.fleuve.parcours[i].posY
                    if(not(randint(0,10)) and posX+int(self.fleuve.largeur/2)+1 < self.nbCelluleLargeur and posX-int(self.fleuve.largeur/2)-1 > 0):
                        self.deplacements.append(Deplacement("pont", posX+int(self.fleuve.largeur/2)+1, posY, posX-int(self.fleuve.largeur/2)-1, posY, self.tailleCellule))
                        i += 5 # Ponts espacés de 4 cellules minimum
                    else:
                        i += 1

        for i in range (0, len(self.zonesUrbaines)-1):
            centerX = self.zonesUrbaines[i].posX
            centerY = self.zonesUrbaines[i].posY
            centerX1 = self.zonesUrbaines[i+1].posX
            centerY1 = self.zonesUrbaines[i+1].posY
            # Voies ferrées
            if ((self.zonesUrbaines[i].genre == "Ville" or self.zonesUrbaines[i].genre == "Metropole") and (self.zonesUrbaines[i+1].genre == "Ville" or self.zonesUrbaines[i+1].genre == "Metropole")):
                self.deplacements.append(Deplacement("voieFerree", centerX, centerY, centerX1, centerY1, self.tailleCellule))



    # Afficher tous les déplacements de la grille
    def afficherDeplacements(self):
        for i in range (0, len(self.deplacements)):
            self.deplacements[i].afficher(self.grille)

    # Affiche la grille
    def afficher(self):
        for y in range(len(self.matCarre)):
            for x in range(len(self.matCarre[0])):
                self.matCarre[y][x].afficher(self.grille, x, y)
        self.afficherDeplacements()


    # Infecte la cellule lorsqu'on clique gauche dessus
    def infecterManu(self, event):
        x = event.x - (event.x%self.tailleCellule)
        y = event.y - (event.y%self.tailleCellule)

        i = int(x/self.tailleCellule)
        j = int(y/self.tailleCellule)

        if(self.matCarre[j][i].etat == "sain"):
            self.matCarre[j][i].setEtat("infecte")
            self.matCarre[j][i].afficher(self.grille, i, j)
            self.afficherDeplacements()
            print("la cellule " + repr(i) + " ; " + repr(j) + " a été infectée.")
            self.nbSain = self.nbSain - 1
            self.nbInfecte = self.nbInfecte + 1

    # Soigne la cellule lorsqu'on clique droit dessus
    def guerirManu(self, event):
        x = event.x -(event.x%self.tailleCellule)
        y = event.y -(event.y%self.tailleCellule)

        i = int(x/self.tailleCellule)
        j = int(y/self.tailleCellule)

        if(self.matCarre[j][i].etat == "infecte"):
            self.matCarre[j][i].setEtat("sain")
            self.matCarre[j][i].afficher(self.grille, i, j)
            self.afficherDeplacements()
            print("la cellule " + repr(i) + " ; " + repr(j) + " a été guérie.")
            self.nbSain = self.nbSain + 1
            self.nbInfecte = self.nbInfecte - 1

    # Défini si la cellule(posX, posY) devient infectée dans la grille matDeTest
    def soumettreAuVirus (self, matDeTest,posX, posY):
        tauxInfection = 0.0
        # 01 02 03 04 05 #
        # 06 07 08 09 10 #
        # 11 12 XX 13 14 #
        # 15 16 17 18 19 #
        # 20 21 22 23 24 #

        #Récupère le nombre de cellule inféctées pour chaque cellule et ajoute si c'est le cas un taux.
        if(posY >= 2):
            if (posX >= 2 and matDeTest[posY-2][posX-2].etat == "infecte"): #1
                tauxInfection = tauxInfection + 0.25
            if (posX >= 1 and matDeTest[posY-2][posX-1].etat == "infecte"): #2
                tauxInfection = tauxInfection + 0.5
            if (posX < self.nbCelluleLargeur and matDeTest[posY-2][posX].etat == "infecte"): #3
                tauxInfection = tauxInfection + 0.75
            if (posX < self.nbCelluleLargeur-1 and matDeTest[posY-2][posX+1].etat == "infecte"): #4
                tauxInfection = tauxInfection + 0.5
            if (posX < self.nbCelluleLargeur-2 and matDeTest[posY-2][posX+2].etat == "infecte"): #5
                tauxInfection = tauxInfection + 0.25

        if(posY >= 1 ):
            if (posX >= 2 and matDeTest[posY-1][posX-2].etat == "infecte"): #6
                tauxInfection = tauxInfection + 0.5
            if (posX >= 1 and matDeTest[posY-1][posX-1].etat == "infecte"): #7
                tauxInfection = tauxInfection + 0.75
            if (posX < self.nbCelluleLargeur and matDeTest[posY-1][posX].etat == "infecte"): #8
                tauxInfection = tauxInfection + 1
            if (posX < self.nbCelluleLargeur-1 and matDeTest[posY-1][posX+1].etat == "infecte"): #9
                tauxInfection = tauxInfection + 0.75
            if (posX < self.nbCelluleLargeur-2 and matDeTest[posY-1][posX+2].etat == "infecte"): #10
                tauxInfection = tauxInfection + 0.5

        if(posY < self.nbCelluleHauteur):
            if (posX >= 2 and matDeTest[posY][posX-2].etat == "infecte"): #11
                tauxInfection = tauxInfection + 0.75
            if (posX >= 1 and matDeTest[posY][posX-1].etat == "infecte"): #12
                tauxInfection = tauxInfection + 1
            if (posX < self.nbCelluleLargeur-1 and matDeTest[posY][posX+1].etat == "infecte"): #13
                tauxInfection = tauxInfection + 1        
            if (posX < self.nbCelluleLargeur-2 and matDeTest[posY][posX+2].etat == "infecte"): #14
                tauxInfection = tauxInfection + 0.75

        if(posY < self.nbCelluleHauteur-1):
            if (posX >= 2 and matDeTest[posY+1][posX-2].etat == "infecte"): #15
                tauxInfection = tauxInfection + 0.5
            if (posX >= 1 and matDeTest[posY+1][posX-1].etat == "infecte"): #16
                tauxInfection = tauxInfection + 0.75
            if (posX < self.nbCelluleLargeur and matDeTest[posY+1][posX].etat == "infecte"): #17
                tauxInfection = tauxInfection + 1
            if (posX < self.nbCelluleLargeur-1 and matDeTest[posY+1][posX+1].etat == "infecte"): #18
                tauxInfection = tauxInfection + 0.75
            if (posX < self.nbCelluleLargeur-2 and matDeTest[posY+1][posX+2].etat == "infecte"): #19
                tauxInfection = tauxInfection + 0.5

        if(posY < self.nbCelluleHauteur-2):
            if (posX >= 2 and matDeTest[posY+2][posX-2].etat == "infecte"): #20
                tauxInfection = tauxInfection + 0.25
            if (posX >= 1 and matDeTest[posY+2][posX-1].etat == "infecte"): #21
                tauxInfection = tauxInfection + 0.5
            if (posX < self.nbCelluleLargeur and matDeTest[posY+2][posX].etat == "infecte"): #22
                tauxInfection = tauxInfection + 0.75
            if (posX < self.nbCelluleLargeur-1 and matDeTest[posY+2][posX+1].etat == "infecte"): #23
                tauxInfection = tauxInfection + 0.5
            if (posX < self.nbCelluleLargeur-2 and matDeTest[posY+2][posX+2].etat == "infecte"): #24
                tauxInfection = tauxInfection + 0.25


        if (tauxInfection > 0):
            #Defini si la cellule devient infectée
            nbAlea = randint(0,100)
            if (nbAlea < tauxInfection*self.virus.tauxReproduction):
                self.matCarre[posY][posX].setEtat("infecte")
                self.matCarre[posY][posX].afficher(self.grille, posX, posY)
                self.nbSain = self.nbSain - 1
                self.nbInfecte = self.nbInfecte + 1

    # Propage le virus jour par jour automatiquement
    def propager (self):
        matDeTest = copy.deepcopy(self.matCarre)
        for y in range(self.nbCelluleHauteur):
            for x in range(self.nbCelluleLargeur):
                if (self.matCarre[y][x].etat == "sain"):
                    self.soumettreAuVirus(matDeTest, x, y)
        self.afficherDeplacements()

    # Propage le virus d'un jour                
    def propagerUneFois (self, event):
        self.propager();

# END Grille


# La classe MonThread permet de lancer un second processus
class MonThread(threading.Thread):
    def __init__(self, grille, compteur):
        threading.Thread.__init__(self)
        self._etat = False
        self._pause = True
        self.grille = grille
        self.compteur = compteur
 
    def run(self):
        self._etat = True
        cpt = 0
        while self._etat:
            if self._pause:
                time.sleep(0.1)
                continue
            time.sleep (0.5)
            grille.propager()
            cpt = cpt +1
            compteur.config(text="Jour " + repr(cpt))
            pct = int(grille.nbInfecte*100/(grille.nbInfecte + grille.nbSain))
            pctInfecte.config(text="Infectes: " + repr(pct) + "%")
            # Arrêt si grille totalement infectée
            if (pct==100):
                self.pause()

 
    def stop(self):
        self._etat = False
        sys.exit("Arrêt du programme...")
 
    def pause(self):
        self._pause = True
 
    def continu(self):
        self._pause = False

#END MonThread


##### MAIN #####

# Création de la fenêtre
root = Tk()
root.title('Propagation virus')

# Création compteur de jour
compteur = Label(root, text="Jour 0")
compteur.pack()

# Affichage du pourcentage de cellules inféctées
pctInfecte = Label(root, text="Infecte : 0%")
pctInfecte.pack()

# Création de la grille représentative de la population
# Paramètres = fenetre, hauteur, largeur, virus, nb de personne dans un carré
grille = Grille(root, 30, 30, Virus("Peste noire"), 5)
grille.afficher()

# Création d'un thread pour la propagation
thread = MonThread(grille, compteur)
thread.start()

# Arrête le processus créé par le thread lorsque la fenêtre est fermée
root.protocol("WM_DELETE_WINDOW", thread.stop)

# Creation des boutons
boutonStart = Button(root, text="Start", command=thread.continu)
boutonStart.pack()
boutonPause = Button(root, text="Pause", command=thread.pause)
boutonPause.pack()
boutonStop = Button(root, text="Stop", command=thread.stop)
boutonStop.pack()

# Lancement de la fenêtre
root.mainloop()