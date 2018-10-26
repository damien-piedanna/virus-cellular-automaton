# -*- cod# -*- coding: utf-8 -*-
############################################################################
#
# Projet de modélisation mathématique
# Groupe :
# - Aurélien ROBINEAU
# - Damien PIEDANNA
# - Nicolas MEYNIEL
# - Axel PISANI
#
############################################################################

from tkinter import *
import time
import threading
from random import *
import copy
from random import *
from math import sqrt


# La classe carré représente une cellule de la grille non peuplée
class Cellule:
    def __init__(self, tailleCellule, etat):

        self.etat = etat
        self.tailleCellule = tailleCellule
        self.setEtat(etat)
        self.carreGraphique = 0

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

        self.carreGraphique = canvas.create_rectangle(x0, y0, x1, y1, fill=self.couleur, width=bordure)

# END Cellule


# La classe CellulePopulation représente une cellule peuplée
class CellulePopulation (Cellule):
    def __init__(self, tailleCellule, etat, moyenneAge):
        self.soigner = False # Défini si la cellule doit être soignée au tour suivant
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
        for i in range (nbPers):
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

# END CellulePopulation


# La classe Position représente une position 2D dans la grille
class Position:
    def __init__(self, posX, posY):
        self.X = posX
        self.Y = posY

    def distance(self, pos):
        # Distance de A à B = racine((Xb-Xa)^2 + (Yb-Ya)^2)
        # On prend la valeur absolue car l'orientation dans le repère ne nous interesse pas
        distance = int(abs(sqrt((pos.X-self.X)*(pos.X-self.X) + (pos.Y-self.Y)*(pos.Y-self.Y))))
        return distance

    def printPos(self):
        print("Position (" + repr(self.X) + ", " + repr(self.Y) + ")")

# END Position


# Classe Fleuve représente un fleuve
class Fleuve:
    def __init__(self, grille):
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
            # Départ à gauche, ne peut pas partir à moins de 5 cellules des bords supérieur et inférieur
            pos = Position(0, randint(5, grille.nbCelluleHauteur-5))
            # Tant que le fleuve n'atteind pas un bord
            while (pos.X < grille.nbCelluleLargeur and pos.Y > 0 and pos.Y < grille.nbCelluleHauteur):
                # On créer une nouvelle cellule du fleuve
                if (grille.matCell[pos.Y][pos.X].etat == "sain"):
                    grille.nbSain -= 1
                grille.matCell[pos.Y][pos.X] = Cellule(grille.tailleCellule, "eau")
                self.parcours.append(pos)

                # On étend la largeur du fleuve
                for i in range (1,int(self.largeur/2)+1):
                    if (pos.Y-i >= 0):
                        if (grille.matCell[pos.Y-i][pos.X].etat == "sain"):
                            grille.nbSain -= 1
                        grille.matCell[pos.Y-i][pos.X] = Cellule(grille.tailleCellule, "eau")
                    if (pos.Y+i < grille.nbCelluleHauteur):
                        if (grille.matCell[pos.Y+i][pos.X].etat == "sain"):
                            grille.nbSain -= 1
                        grille.matCell[pos.Y+i][pos.X] = Cellule(grille.tailleCellule, "eau")

                # Position de la prochaine cellule du fleuve
                pos.X += 1
                pos.Y = randint(pos.Y-1, pos.Y+1)
                pos = copy.deepcopy(pos) # Pos pointe sur une nouvele case mémoire
        else:
            self.departAGauche = False
            # Départ en haut, ne peut pas partir à moins de 5 cellules des bords gauche et droit
            pos = Position(randint(5, grille.nbCelluleLargeur-5), 0)
            # Tant que le fleuve n'atteind pas un bord
            while (pos.Y < grille.nbCelluleHauteur and pos.X > 0 and pos.X < grille.nbCelluleLargeur):
                # On créer une nouvelle cellule du fleuve
                if (grille.matCell[pos.Y][pos.X].etat == "sain"):
                    grille.nbSain -= 1
                grille.matCell[pos.Y][pos.X] = Cellule(grille.tailleCellule, "eau")
                self.parcours.append(pos)

                # On étend la largeur du fleuve
                for i in range (1,int(self.largeur/2)+1):
                    if (pos.X-i >= 0):
                        if (grille.matCell[pos.Y][pos.X-i].etat == "sain"):
                            grille.nbSain -= 1
                        grille.matCell[pos.Y][pos.X-i] = Cellule(grille.tailleCellule, "eau")
                    if (pos.X+i < grille.nbCelluleLargeur):
                        if (grille.matCell[pos.Y][pos.X+1].etat == "sain"):
                            grille.nbSain -= 1
                        grille.matCell[pos.Y][pos.X+i] = Cellule(grille.tailleCellule, "eau")

                # Position de la prochaine cellule du fleuve
                pos.X = randint(pos.X-1, pos.X+1)
                pos.Y += 1
                pos = copy.deepcopy(pos) # Pos pointe sur une nouvele case mémoire

# END Fleuve


# La classe zone urbaine représente des regroupements de population sur la grille
class ZoneUrbaine:
    def __init__(self, grille, genre):
        self.genre = genre # (Metropole, Ville, ZonePeuplee, Village)
        self.pos = Position(randint(0, grille.nbCelluleLargeur-1), randint(0, grille.nbCelluleHauteur-1))
        self.nbSain = 0
        self.nbInfecte = 0

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
    def distanceAuCentre(self, position):
        return position.distance(self.pos)

    # Renvoie True si le point (posX, posY) appartient à la zone courante
    def contient(self, position):
        if (self.distanceAuCentre(position) <= self.rayon):
            return True;
        return False;

    # Renvoie True si la zone courante chevauche la zone zoneUrbaine
    def chevauche(self, zoneUrbaine):
        distanceZones = zoneUrbaine.distanceAuCentre(self.pos)
        if (distanceZones < self.rayon + zoneUrbaine.rayon):
            return True
        return False

# END ZoneUrbaine


# La classe Deplacement représente un moyen de transport allant d'un point à un autre
class Deplacement:
    def __init__(self, etat, pos1, pos2, tailleCellule):
        self.setEtat(etat)
        self.pos1 = pos1
        self.pos2 = pos2
        self.tailleCellule = tailleCellule

    def setEtat (self, etat):
        self.etat = etat
        if (self.etat == "pont"):
            self.couleur = 'lime'
            self.probaVoyage = 100
            self.vitesse = 1 # en nombre de fois la distance toutes les 0.025sec
        elif (self.etat == "route"):
            self.couleur = 'brown'
            self.probaVoyage = 5
            self.vitesse = 0.02 # en nombre de fois la distance toutes les 0.025sec
        elif (self.etat == "voieFerree"):
            self.couleur = 'orange'
            self.probaVoyage = 3
            self.vitesse = 0.05 # en nombre de fois la distance toutes les 0.025sec
        elif (self.etat == "ligneAerienne"):
            self.couleur = 'pink'
            self.probaVoyage = 1
            self.vitesse = 0.1 # en nombre de fois la distance toutes les 0.025sec
        else: # donc cellule inconnue
            self.couleur = 'yellow'
            self.probaVoyage = 0
            self.vitesse = 0 # en nombre de fois la distance toutes les 0.025sec

    def afficher (self, canvas):
        x0 = self.pos1.X*self.tailleCellule + int(10/100 * self.tailleCellule)
        y0 = self.pos1.Y*self.tailleCellule + int(10/100 * self.tailleCellule)
        x1 = (self.pos1.X*self.tailleCellule)+self.tailleCellule - int(10/100 * self.tailleCellule)
        y1 = (self.pos1.Y*self.tailleCellule)+self.tailleCellule - int(10/100 * self.tailleCellule)
        canvas.create_oval(x0, y0, x1, y1, fill=self.couleur, width=0)

        x0 = self.pos2.X*self.tailleCellule + int(10/100 * self.tailleCellule)
        y0 = self.pos2.Y*self.tailleCellule + int(10/100 * self.tailleCellule)
        x1 = (self.pos2.X*self.tailleCellule)+self.tailleCellule - int(10/100 * self.tailleCellule)
        y1 = (self.pos2.Y*self.tailleCellule)+self.tailleCellule - int(10/100 * self.tailleCellule)
        canvas.create_oval(x0, y0, x1, y1, fill=self.couleur, width=0)
        
        x0 = self.pos1.X*self.tailleCellule + int(self.tailleCellule/2)
        y0 = self.pos1.Y*self.tailleCellule + int(self.tailleCellule/2)
        x1 = self.pos2.X*self.tailleCellule + int(self.tailleCellule/2)
        y1 = self.pos2.Y*self.tailleCellule + int(self.tailleCellule/2)

        epaisseur = int(20/100 * self.tailleCellule)
        if (self.etat == "pont"):
            epaisseur = self.tailleCellule - int(20/100 * self.tailleCellule)
        if (epaisseur < 3):
            epaisseur = 3 # Sinon difficilement visible

        canvas.create_line(x0, y0, x1, y1, fill=self.couleur, width=epaisseur)

# END Deplacement


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

        self.matCell = []

        self.deplacements = []

        # Affectation des actions de la souris
        self.grille.bind("<Button-1>", self.infecterManu)
        self.grille.bind("<Button-2>", self.propagerUneFois)
        self.grille.bind("<Button-3>", self.guerirManu)
        self.grille.pack()

        # Création des zones urbaines
        self.zonesUrbaines = self.genererZonesUrbaines()

        #Crée les carrés composant la grille et les range dans une matrice
        for y in range (nbCelluleHauteur):
            ligne = []
            for x in range (nbCelluleLargeur):
                estDansUneZoneUrbaine = False

                # Parcours de toutes les zones urbaines de la grille
                for i in range (len(self.zonesUrbaines)):
                    zoneUrbaine = self.zonesUrbaines[i]
                    if (zoneUrbaine.contient(Position(x,y))):
                        if (zoneUrbaine.genre == "ZonePeuplee"):
                            if (randint(1,3) == 1): # 1 chance sur 4 qu'un carré soit peuplé dans une zone peuplée
                                ageMoy = CellulePopulation.genenerAgeMoyen(self.nbPers)
                                ligne.append(CellulePopulation(self.tailleCellule, "sain", ageMoy))
                                self.nbSain = self.nbSain + 1
                                # Mise à jour population par zone urbaine
                                for numZone in range (len(self.zonesUrbaines)):
                                    zone = self.zonesUrbaines[numZone]
                                    if (zone.contient(Position(x,y))):
                                        zone.nbSain += 1
                            else:
                                ligne.append(Cellule(self.tailleCellule, "vide"))
                        else:
                            probaPop = (-75/zoneUrbaine.rayon)*zoneUrbaine.distanceAuCentre(Position(x,y)) + 100 # Calcul expliqué dans le fichier calculsZone.txt
                            if (randint(0,100) < probaPop): # Plus on est loin du centre moins la population est dense
                                ageMoy = CellulePopulation.genenerAgeMoyen(self.nbPers)
                                ligne.append(CellulePopulation(self.tailleCellule, "sain", ageMoy))
                                self.nbSain = self.nbSain + 1
                                # Mise à jour population par zone urbaine
                                for numZone in range (len(self.zonesUrbaines)):
                                    zone = self.zonesUrbaines[numZone]
                                    if (zone.contient(Position(x,y))):
                                        zone.nbSain += 1
                            else:
                                ligne.append(Cellule(self.tailleCellule, "vide"))
                        estDansUneZoneUrbaine = True
                        break # Pas besoin de parcourir les autres zones car une cellule ne peut être que dans une seule zone

                if(not(estDansUneZoneUrbaine)):
                    if (randint(1,6) == 1): # 1 chance sur 8 qu'un carré soit peuplé si il est en dehors d'une zone urbaine
                        ageMoy = CellulePopulation.genenerAgeMoyen(self.nbPers)
                        ligne.append(CellulePopulation(self.tailleCellule, "sain", ageMoy))
                        self.nbSain = self.nbSain + 1
                        # Mise à jour population par zone urbaine
                        for numZone in range (len(self.zonesUrbaines)):
                            zone = self.zonesUrbaines[numZone]
                            if (zone.contient(Position(x,y))):
                                zone.nbSain += 1
                    else:
                        ligne.append(Cellule(self.tailleCellule, "vide"))

            self.matCell.append(ligne)
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
        if(randint(1,6) == 1): # 1 chance sur 6 qu'il est une métropole
            metropole = ZoneUrbaine(self,"Metropole")
            zonesUrbaines.append(metropole)
        for i in range (randint(2,4)): # Entre 2 et 4 villes
            for j in range (10): # Créer une nouvelle zone tant qu'elle en chevauche une autre (10 essai max avant abandon)
                zone = ZoneUrbaine(self,"Ville")
                nbZonesChevauchees = 0
                for i in range (len(zonesUrbaines)):
                    if (zone.chevauche(zonesUrbaines [i])):
                        nbZonesChevauchees = nbZonesChevauchees + 1
                if (nbZonesChevauchees == 0):
                    zonesUrbaines.append(zone)
                    break
        for i in range (randint(5,10)): # Entre 5 et 10 villages
            for j in range (10): # Créer une nouvelle zone tant qu'elle en chevauche une autre (10 essai max avant abandon)
                zone = ZoneUrbaine(self,"Village")
                nbZonesChevauchees = 0
                for i in range (len(zonesUrbaines)):
                    if (zone.chevauche(zonesUrbaines [i])):
                        nbZonesChevauchees = nbZonesChevauchees + 1
                if (nbZonesChevauchees == 0):
                    zonesUrbaines.append(zone)
                    break
        for i in range (randint(0,2)): # Entre 0 et 2 zones peuplées
            for j in range (10): # Créer une nouvelle zone tant qu'elle en chevauche une autre (10 essai max avant abandon)
                zone = ZoneUrbaine(self,"ZonePeuplee")
                nbZonesChevauchees = 0
                for i in range (len(zonesUrbaines)):
                    if (zone.chevauche(zonesUrbaines [i])):
                        nbZonesChevauchees = nbZonesChevauchees + 1
                if (nbZonesChevauchees == 0):
                    zonesUrbaines.append(zone)
                    break

        return zonesUrbaines

    # Génère tous les déplacements de la grille
    def genererDeplacements(self):
        # Taille minimal pour générer un fleuve
        if(self.nbCelluleLargeur >= 30 and self.nbCelluleHauteur >= 30):
            # Création des ponts
            if (self.fleuve.departAGauche):
                i = 0
                while (i < len(self.fleuve.parcours)):
                    pos = self.fleuve.parcours[i]
                    if(not(randint(0,12)) and pos.Y+int(self.fleuve.largeur/2)+1 < self.nbCelluleHauteur and pos.Y-int(self.fleuve.largeur/2)-1 >= 0 and pos.X >= 0 and pos.X < self.nbCelluleLargeur):
                        # Les cellules de départ et d'arrivée doivent être peuplées
                        if (self.matCell[pos.Y+int(self.fleuve.largeur/2)+1][pos.X].etat == "vide"):
                            self.matCell[pos.Y+int(self.fleuve.largeur/2)+1][pos.X] = CellulePopulation(self.tailleCellule, "sain", CellulePopulation.genenerAgeMoyen(self.nbPers))
                            self.nbSain += 1
                        if (self.matCell[pos.Y-int(self.fleuve.largeur/2)-1][pos.X].etat == "vide"):
                            self.matCell[pos.Y-int(self.fleuve.largeur/2)-1][pos.X] = CellulePopulation(self.tailleCellule, "sain", CellulePopulation.genenerAgeMoyen(self.nbPers))
                            self.nbSain += 1
                        self.deplacements.append(Deplacement("pont", Position(pos.X, pos.Y+int(self.fleuve.largeur/2)+1), Position(pos.X, pos.Y-int(self.fleuve.largeur/2)-1), self.tailleCellule))
                        i += 5 # Ponts espacés de 4 cellules minimum
                    else:
                        i += 1
            else: # Depart en haut
                i = 0
                while (i < len(self.fleuve.parcours)):
                    pos = self.fleuve.parcours[i]
                    if(not(randint(0,12)) and pos.X+int(self.fleuve.largeur/2)+1 < self.nbCelluleLargeur and pos.X-int(self.fleuve.largeur/2)-1 >= 0 and pos.Y >= 0 and pos.Y < self.nbCelluleHauteur):
                        if (self.matCell[pos.Y][pos.X+int(self.fleuve.largeur/2)+1].etat == "vide"):
                            self.matCell[pos.Y][pos.X+int(self.fleuve.largeur/2)+1] = CellulePopulation(self.tailleCellule, "sain", CellulePopulation.genenerAgeMoyen(self.nbPers))
                            self.nbSain += 1
                        if (self.matCell[pos.Y][pos.X-int(self.fleuve.largeur/2)-1].etat == "vide"):
                            self.matCell[pos.Y][pos.X-int(self.fleuve.largeur/2)-1] = CellulePopulation(self.tailleCellule, "sain", CellulePopulation.genenerAgeMoyen(self.nbPers))
                            self.nbSain += 1
                        self.deplacements.append(Deplacement("pont", Position(pos.X+int(self.fleuve.largeur/2)+1, pos.Y), Position(pos.X-int(self.fleuve.largeur/2)-1, pos.Y), self.tailleCellule))
                        i += 5 # Ponts espacés de 4 cellules minimum
                    else:
                        i += 1

        # Création des autres déplacements
        concatener(self.deplacements, algoPrim(self, "route"))
        concatener(self.deplacements, algoPrim(self, "voieFerree"))
        concatener(self.deplacements, algoPrim(self, "ligneAerienne"))

    def lancerVoyages(self):
        for i in range (len(self.deplacements)):
            deplacement = self.deplacements[i]
            # Probabilité qu'un voyage soit réalisé
            if (randint(0, 100) < deplacement.probaVoyage):
                # Une chance sur deux que le voyage soit dans un sens ou dans l'autre
                if (randint(0,1)):
                    depart = deplacement.pos1
                    arrivee = deplacement.pos2
                else:
                    depart = deplacement.pos2
                    arrivee = deplacement.pos1
                # Les ponts gérés différement
                if (deplacement.etat != "pont"):
                    # Récupération de la zone urbaine de départ
                    zone = 0
                    for numZone in range (len(self.zonesUrbaines)):
                        zone = self.zonesUrbaines[numZone]
                        if (zone.pos == depart):
                            break

                    # On détermine si le voyageur est sain en fonction du nombre de sains dans la zone de départ
                    if (zone.nbSain+zone.nbInfecte == 0):
                        tauxInfecte = 0
                    else:
                        tauxInfecte = (zone.nbInfecte*100/(zone.nbSain+zone.nbInfecte))

                    if (randint(0, 100) < tauxInfecte):
                        voyageur = "infecte"
                    else:
                        voyageur = "sain"

                    anim = ThreadAnimation(self, deplacement, depart, arrivee, voyageur)
                    anim.start()

                else: # Le déplacement est un pont
                    if (self.matCell[depart.Y][depart.X].etat == "infecte"):
                        if(self.matCell[arrivee.Y][arrivee.X].etat == "sain"):
                            self.matCell[arrivee.Y][arrivee.X].setEtat("infecte")
                            self.nbInfecte += 1
                            self.nbSain -= 1
                            self.grille.itemconfig(self.matCell[arrivee.Y][arrivee.X].carreGraphique, fill='red')

    # Afficher tous les déplacements de la grille
    def afficherDeplacements(self):
        for i in range (len(self.deplacements)):
            self.deplacements[i].afficher(self.grille)

    # Affiche la grille
    def afficher(self):
        for y in range(len(self.matCell)):
            for x in range(len(self.matCell[0])):
                self.matCell[y][x].afficher(self.grille, x, y)
        self.afficherDeplacements()
        self.grille.update()


    # Infecte la cellule lorsqu'on clique gauche dessus
    def infecterManu(self, event):
        x = event.x - (event.x%self.tailleCellule)
        y = event.y - (event.y%self.tailleCellule)

        i = int(x/self.tailleCellule)
        j = int(y/self.tailleCellule)

        if(self.matCell[j][i].etat == "sain"):
            self.matCell[j][i].setEtat("infecte")
            self.grille.itemconfig(self.matCell[j][i].carreGraphique, fill='red')
            print("Cellule (" + repr(i) + " ; " + repr(j) + ") infectée manuellement.")
            self.nbSain -= 1
            self.nbInfecte += 1
            for numZone in range (len(self.zonesUrbaines)):
                zone = self.zonesUrbaines[numZone]
                if (zone.contient(Position(i,j))):
                    zone.nbSain -= 1
                    zone.nbInfecte += 1

    # Soigne la cellule lorsqu'on clique droit dessus
    def guerirManu(self, event):
        x = event.x -(event.x%self.tailleCellule)
        y = event.y -(event.y%self.tailleCellule)

        i = int(x/self.tailleCellule)
        j = int(y/self.tailleCellule)

        if(self.matCell[j][i].etat == "infecte"):
            self.matCell[j][i].setEtat("sain")
            self.grille.itemconfig(self.matCell[j][i].carreGraphique, fill='green')
            print("Cellule (" + repr(i) + " ; " + repr(j) + ") guérie manuellement.")
            self.nbSain += 1
            self.nbInfecte -= 1
            for numZone in range (len(self.zonesUrbaines)):
                zone = self.zonesUrbaines[numZone]
                if (zone.contient(Position(i,j))):
                    zone.nbSain += 1
                    zone.nbInfecte -= 1

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
                self.matCell[posY][posX].setEtat("infecte")
                self.grille.itemconfig(self.matCell[posY][posX].carreGraphique, fill='red')
                self.nbSain = self.nbSain - 1
                self.nbInfecte = self.nbInfecte + 1
                for numZone in range (len(self.zonesUrbaines)):
                    zone = self.zonesUrbaines[numZone]
                    if (zone.contient(Position(posX,posY))):
                        zone.nbSain -= 1
                        zone.nbInfecte += 1

    # Propage le virus jour par jour automatiquement
    def propager (self):
        matDeTest = copy.deepcopy(self.matCell)
        for y in range(self.nbCelluleHauteur):
            for x in range(self.nbCelluleLargeur):
                if (self.matCell[y][x].etat == "sain"):
                    self.soumettreAuVirus(matDeTest, x, y)
                elif (self.matCell[y][x].etat == "infecte" and self.matCell[y][x].soigner == True): # Soigne les cellules infectées temporairement
                    self.matCell[y][x].soigner = False
                    self.matCell[y][x].setEtat("sain")
                    self.nbInfecte -= 1
                    self.nbSain += 1
                    self.grille.itemconfig(self.matCell[y][x].carreGraphique, fill='green')
        self.lancerVoyages()

    # Propage le virus d'un jour                
    def propagerUneFois (self, event):
        self.propager()

# END Grille


# La classe ThreadCommands permet de lancer un second processus
class ThreadCommands(threading.Thread):
    def __init__(self, grille, compteur, pctInfecte):
        threading.Thread.__init__(self)
        self._actif = False
        self._pause = True
        self.grille = grille
        self.compteur = compteur
        self.pctInfecte = pctInfecte
 
    def run(self):
        self._actif = True
        cpt = 0
        while self._actif:
            if self._pause:
                time.sleep(0.1)
                continue
            time.sleep (0.5)
            self.grille.propager()
            cpt = cpt +1
            self.compteur.config(text="Jour " + repr(cpt))
            pct = int(self.grille.nbInfecte*100/(self.grille.nbInfecte + self.grille.nbSain))
            self.pctInfecte.config(text="Infectes: " + repr(pct) + "%")
            # Arrêt si grille totalement infectée
            if (pct>=100):
                self.pause()
 
    def stop(self):
        self._actif = False
        sys.exit("Arrêt du programme...")
 
    def pause(self):
        self._pause = True
 
    def continu(self):
        self._pause = False

# END ThreadCommands


# La classe ThreadCommands permet l'affichage des voyages
class ThreadAnimation(threading.Thread):
    def __init__(self, grille, deplacement, depart, arrivee, voyageur):
        threading.Thread.__init__(self)
        print("init anim")
        self.grille = grille
        self.deplacement = deplacement
        self.depart = depart
        self.arrivee = arrivee
        self.voyageur = voyageur
 
    def run(self):
    	print("run trhad")
        if(self.voyageur == "sain"):
            couleur = 'green'
        else:
            couleur = 'red'
        
        # Le cercle représentant le voyageur est de diamètre 80% de la taille d'une cellule, mais minimum 16 pixels
        if (self.grille.tailleCellule < 16):
            rayon = 8
        else:
            rayon = int(40/100 * self.grille.tailleCellule)

        x0 = self.depart.X*self.grille.tailleCellule + int(self.grille.tailleCellule/2) - rayon
        y0 = self.depart.Y*self.grille.tailleCellule + int(self.grille.tailleCellule/2) - rayon
        x1 = self.depart.X*self.grille.tailleCellule + int(self.grille.tailleCellule/2) + rayon
        y1 = self.depart.Y*self.grille.tailleCellule + int(self.grille.tailleCellule/2) + rayon

        train = self.grille.grille.create_oval(x0, y0, x1, y1, fill=couleur, width=2)
        self.grille.grille.update()

        deltaX = (self.arrivee.X - self.depart.X)*self.grille.tailleCellule
        deltaY = (self.arrivee.Y - self.depart.Y)*self.grille.tailleCellule

        # Tant que le rond n'est pas à l'arrivée
        while(Position(self.grille.grille.coords(train)[0], self.grille.grille.coords(train)[1]).distance(Position(self.depart.X*self.grille.tailleCellule, self.depart.Y*self.grille.tailleCellule)) < Position(self.depart.X*self.grille.tailleCellule, self.depart.Y*self.grille.tailleCellule).distance(Position(self.arrivee.X*self.grille.tailleCellule, self.arrivee.Y*self.grille.tailleCellule))):
            self.grille.grille.move(train, deltaX*self.deplacement.vitesse, deltaY*self.deplacement.vitesse)
            self.grille.grille.update()
            time.sleep(0.025)

        self.grille.grille.delete(train)

        if (self.voyageur == "infecte"):
            if(self.grille.matCell[self.arrivee.Y][self.arrivee.X].etat == "sain"):
                self.grille.matCell[self.arrivee.Y][self.arrivee.X].soigner = True # La cellule d'arrivée n'est infectée que pendant un tour
                self.grille.matCell[self.arrivee.Y][self.arrivee.X].setEtat("infecte")
                self.grille.nbInfecte += 1
                self.grille.nbSain -= 1
                self.grille.grille.itemconfig(self.grille.matCell[arrivee.Y][arrivee.X].carreGraphique, fill='red')

# END ThreadAnimation


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
# END Virus


# Execute l'algorithme de prim sur le graphe complet composé des centres de toutes
# les zones urbaines de 'grille' pouvant comporter un deplacement de type 'genre'
# Le graphe généré est composé de déplacements.
def algoPrim(grille, genre):
    zones = grille.zonesUrbaines
    sommets = []
    i = 0

    # Les routes relient tous types de zones urbaines sauf les zones peuplées
    if (genre == "route"):
        genreExclu = "ZonePeuplee"
    # Les voies ferrées relient les métropoles et les villes
    elif(genre == "voieFerree"):
        genreExclu = "Village"
    # Les lignes aériennes relient seulement les métropoles
    elif(genre == "ligneAerienne"):
        genreExclu = "Ville"
    else:
        return []

    # Pour tous les centres des zones en parametre
    while (i < len(zones) and zones[i].genre != genreExclu):
        # Si le centre de la ville n'est pas une case saine on ne le prend pas (par exemple si c'est un fleuve)
        if (grille.matCell[zones[i].pos.Y][zones[i].pos.X].etat == "sain"):
            sommets.append(zones[i].pos)
        i += 1

    # On quitte s'il n'y a pas d'arête possible
    if (len(sommets) < 2):
        return []

    dep = [] # Déplacements créés
    som = [] # Sommets déjà dans un déplacement
    som.append(sommets[0]) # Sommet de départ

    # Tant que tous les sommets ne sont pas reliés (nbAretes = nbSommets-1)
    while (len(dep) < len(sommets)-1):
        # distancePrev initialisée à une distance > à la distance max entre 2 cellules
        distancePrev = Position(0,0).distance(Position(grille.nbCelluleLargeur+1,grille.nbCelluleHauteur+1))

        # Déclaration des positions
        sommet1 = Position(0,0)
        sommet2 = Position(0,0)

        # Parcours de tous les couples de sommets
        for i in range (len(sommets)):
            for j in range (len(sommets)):
                testerArete = False
                som1Visit = False
                som2Visit = False

                for s in range (len(som)):
                    if (sommets[i].X == som[s].X and sommets[i].Y == som[s].Y):
                        som1Visit = True
                    if (sommets[j].X == som[s].X and sommets[j].Y == som[s].Y):
                        som2Visit = True
                # On ne teste l'arête qui si elle commence dans un sommet du nouveau graphe mais se termine en dehors
                if (som1Visit and not(som2Visit)):
                    testerArete = True
    
                # On cherche l'arête de plus petit poids
                if (testerArete and sommets[i].distance(sommets[j]) < distancePrev):
                    distancePrev = sommets[i].distance(sommets[j])
                    sommet1 = sommets[i]
                    sommet2 = sommets[j]

        dep.append(Deplacement(genre, sommet1, sommet2, grille.tailleCellule))
        som.append(sommet1)
        som.append(sommet2)

    return dep


# Concatène 2 listes
def concatener(liste1, liste2):
    for i in range (len(liste2)):
        liste1.append(liste2[i])


# Lance la simulation
def lancerSimulation():
	# Test si les entrées sont bien des entiers
	try:	
		nbCellulesHauteur = int(hauteurEntry.get())
		nbCellulesLargeur = int(largeurEntry.get())
	except ValueError:
		return

	# La grille ne peut pas faire moins de 1px de largeur ou de hauteur
	if (nbCellulesHauteur < 1 or nbCellulesLargeur < 1):
		return

	nomVirus = var.get()

	# Création de la fenêtre
	simulation = Tk()
	simulation.title('Propagation ' + nomVirus)

	# Création compteur de jour
	compteur = Label(simulation, text="Jour 0")
	compteur.pack()

	# Affichage du pourcentage de cellules inféctées
	pctInfecte = Label(simulation, text="Infecte : 0%")
	pctInfecte.pack()

	# Affiche le nom du virus
	Label(simulation, text="Virus : " + nomVirus).pack()

	# Création de la grille représentative de la population
	# Paramètres = fenetre, hauteur, largeur, nomVirus, nb de personne dans un carré
	grille = Grille(simulation, nbCellulesHauteur, nbCellulesLargeur, Virus(nomVirus), 5)
	grille.afficher()

	# Création d'un thread pour la propagation
	commandes = ThreadCommands(grille, compteur, pctInfecte)
	commandes.start()

	# Arrête le processus créé par le thread lorsque la fenêtre est fermée
	simulation.protocol("WM_DELETE_WINDOW", commandes.stop)

	# Creation des boutons
	boutonStart = Button(simulation, text="Start", command=commandes.continu)
	boutonStart.pack(side="left")
	boutonPause = Button(simulation, text="Pause", command=commandes.pause)
	boutonPause.pack(side="left")
	boutonStop = Button(simulation, text="Stop", command=commandes.stop)
	boutonStop.pack(side="left")

	# Lancement de la fenêtre
	simulation.mainloop()


# FONCTION MAIN

virus = ["Peste noire", "Rougeole", "Coqueluche", "Diphtérie", "Variole", "Poliomyélite", "Grippe"]
radioVirus = []

root = Tk()

root.title('Menu')

# Entrée nombre de cellules hauteur
Label(root, text="Nombre de cellule en hauteur").pack()
hauteurDefaut = StringVar(root, value='60')
hauteurEntry = Entry(root, textvariable=hauteurDefaut, borderwidth=5)
hauteurEntry.pack()

# Entrée nombre de cellules largeur
Label(root, text="Nombre de cellule en largeur").pack()
largeurDefaut = StringVar(root, value='90')
largeurEntry = Entry(root, textvariable=largeurDefaut, borderwidth=5)
largeurEntry.pack()

# Proposition des virus
var = StringVar()
Label(root, text="Choisir le virus").pack()
for i in range (len(virus)):
	radioVirus.append(Radiobutton(root, text=virus[i], variable=var, value=virus[i],borderwidth=5))
	radioVirus[i].pack()

# On selectionne par defaut le premier virus
for radio in radioVirus:
	radio.deselect()
radioVirus[0].select()

# Bouton pour lancer la simulation
boutonBegin = Button(root, text="Commencer", command=lancerSimulation, activebackground="chartreuse", background="lime green", borderwidth=5)
boutonBegin.pack()

root.mainloop()
