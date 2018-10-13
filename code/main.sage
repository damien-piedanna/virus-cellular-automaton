# -*- cod# -*- coding: utf-8 -*-

#https://fr.statista.com/statistiques/472349/repartition-population-groupe-dage-france/
#https://www.insee.fr/fr/statistiques/1892088?sommaire=1912926


from tkinter import *
from random import *
from math import sqrt
import time
import threading
import copy

class Carre:
    def __init__(self, tailleCellule, etat):

        self.etat = etat
        self.tailleCellule = tailleCellule
        
        if (self.etat == "mur"):
            self.couleur = 'black'
        else: # donc case vide
            self.couleur = 'white'

    def afficher (self, canvas, x, y):
        canvas.create_rectangle(x*self.tailleCellule, y*self.tailleCellule, (x*self.tailleCellule)+self.tailleCellule, (y*self.tailleCellule)+self.tailleCellule, fill=self.couleur, width = 1)

    def setEtat (self, etat):
        self.etat = etat;
        if (self.etat == "mur"):
            self.couleur = 'black'
        else: # donc case vide
            self.couleur = 'white'

#END Carre


class CarrePopulation (Carre):
    def __init__(self, tailleCellule, etat, moyenneAge):

        self.tailleCellule = tailleCellule
        self.etat = etat
        self.moyenneAge = moyenneAge

        if (self.etat == "sain"):
            self.couleur = 'green'
        elif (self.etat == "infecte"):
            self.couleur = 'red'
        else: # donc case inconnue
            self.couleur = 'yellow'

    def setEtat (self, etat):
        self.etat = etat
        if (self.etat == "sain"):
            self.couleur = 'green'
        elif (self.etat == "infecte"):
            self.couleur = 'red'
        else: # donc case inconnue
            self.couleur = 'yellow'

#END Carre_population


class Virus:
    def __init__(self, label):
        self.label = label
        if (self.label == "Peste noire"):
            self.tauxReproduction = 12.5
        else:
            self.tauxReproduction = 5

#END Virus


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
        elif (self.genre == "ZonePeuplee"): # Rayon entre 1/8 et 1/2 de la taille maximale de la grille
            if (grille.nbCelluleHauteur < grille.nbCelluleLargeur):
                self.rayon = randint(int(grille.nbCelluleHauteur/8), int(grille.nbCelluleHauteur/2))
            else:
                self.rayon = randint(int(grille.nbCelluleLargeur/8), int(grille.nbCelluleLargeur/2))
        elif (self.genre == "Village"): # Rayon entre 1/8 et 1/2 de la taille maximale de la grille
            if (grille.nbCelluleHauteur < grille.nbCelluleLargeur):
                self.rayon = randint(int(grille.nbCelluleHauteur/16), int(grille.nbCelluleHauteur/10))
            else:
                self.rayon = randint(int(grille.nbCelluleLargeur/16), int(grille.nbCelluleLargeur/10))
        else: #Zone inconnue
            self.rayon = 0

    def distanceAuCentre(self, posX, posY):
        # Distance de A à B = racine((Xb-Xa)^2 + (Yb-Ya)^2)
        # On prend la valeur absolue car l'orientation dans le repère ne nous interesse pas
        distance = int(abs(sqrt((posX-self.posX)*(posX-self.posX) + (posY-self.posY)*(posY-self.posY))))
        return distance

    def contient(self, posX, posY):
        if (self.distanceAuCentre(posX, posY) <= self.rayon):
            return True;
        return False;

    def chevauche(self, zoneUrbaine):
        distanceZones = zoneUrbaine.distanceAuCentre(self.posX, self.posY)
        if (distanceZones < self.rayon + zoneUrbaine.rayon):
            return True
        return False

#END Vile


class Grille:
    def __init__(self, hauteurEcranPx, largeurEcranPx, nbCelluleHauteur, nbCelluleLargeur, virus, nbPers):
        print("Génération de la grille...")

        self.nbCelluleHauteur = nbCelluleHauteur
        self.nbCelluleLargeur = nbCelluleLargeur

        self.tailleCellule = int((hauteurEcranPx-200)/nbCelluleHauteur)
        if (nbCelluleLargeur*self.tailleCellule > largeurEcranPx):
            self.tailleCellule = int(largeurEcranPx/nbCelluleLargeur)

        self.nbInfecte = 0
        self.nbSain = 0

        self.grille = Canvas(root, width=self.tailleCellule*nbCelluleLargeur, height=self.tailleCellule*self.nbCelluleHauteur, background='white')

        self.matCarre = []

        self.grille.bind("<Button-1>", self.infecter)
        self.grille.bind("<Button-2>", self.propagerUneFois)
        self.grille.bind("<Button-3>", self.guerir)
        self.grille.pack()

        self.virus = virus
        self.nbPers = nbPers

        self.zonesUrbaines = self.genererZonesUrbaines()

        #Créé les carrés composant la grille et les range dans une matrice
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
                                ageMoy = self.genenerAgeMoyen();
                                ligne.append(CarrePopulation(self.tailleCellule, "sain", ageMoy))
                                self.nbSain = self.nbSain + 1
                            else:
                                ligne.append(Carre(self.tailleCellule, "vide"))
                        else:
                            probaPop = (-75/zoneUrbaine.rayon)*zoneUrbaine.distanceAuCentre(x,y) + 100 # Calcul expliqué dans le fichier calculsZone.txt
                            if (randint(0,100) < probaPop): # Plus on est loin du centre moins la population est dense
                                ageMoy = self.genenerAgeMoyen()
                                ligne.append(CarrePopulation(self.tailleCellule, "sain", ageMoy))
                                self.nbSain = self.nbSain + 1
                            else:
                                ligne.append(Carre(self.tailleCellule, "vide"))
                        estDansUneZoneUrbaine = True
                        break # Pas besoin de parcourir les autres zones car une case ne peut être que dans une seule zone

                if(not(estDansUneZoneUrbaine)):
                    if (randint(1,8) == 1): # 1 chance sur 8 qu'un carré soit peuplé si il est en dehors d'une zone urbaine
                        ageMoy = self.genenerAgeMoyen()
                        ligne.append(CarrePopulation(self.tailleCellule, "sain", ageMoy))
                        self.nbSain = self.nbSain + 1
                    else:
                        ligne.append(Carre(self.tailleCellule, "vide"))

            self.matCarre.append(ligne)
        print("Grille générée !")

    def genererZonesUrbaines(self):
        zonesUrbaines = []

        if(randint(1,8) == 1): # 1 chance sur 8 qu'il est une métropole
            metropole = ZoneUrbaine(self,"Metropole")
            zonesUrbaines.append(metropole)
        for i in range (0, randint(1,3)): # Entre 1 et 2 villes
            while(True): # Créer une nouvelle zone tant qu'elle en chevauche une autre
                zone = ZoneUrbaine(self,"Ville")
                nbZonesChevauchees = 0
                for i in range (0, len(zonesUrbaines)):
                    if (zone.chevauche(zonesUrbaines [i])):
                        nbZonesChevauchees = nbZonesChevauchees + 1
                if (nbZonesChevauchees == 0):
                    zonesUrbaines.append(zone)
                    break
        for i in range (0, randint(0,2)): # Entre 0 et 2 zones peuplées
            while(True): # Créer une nouvelle zone tant qu'elle en chevauche une autre
                zone = ZoneUrbaine(self,"ZonePeuplee")
                nbZonesChevauchees = 0
                for i in range (0, len(zonesUrbaines)):
                    if (zone.chevauche(zonesUrbaines [i])):
                        nbZonesChevauchees = nbZonesChevauchees + 1
                if (nbZonesChevauchees == 0):
                    zonesUrbaines.append(zone)
                    break
        for i in range (0, randint(3,7)): # Entre 3 et 7 villages
            while(True): # Créer une nouvelle zone tant qu'elle en chevauche une autre
                zone = ZoneUrbaine(self,"Village")
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

    def genenerAgeMoyen(self):
        ageMoy = 0
        for i in range (0, self.nbPers):
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

        ageMoy = round(ageMoy/self.nbPers)
        return ageMoy

    #affiche la grille
    def afficher(self):
        for y in range(len(self.matCarre)):
            for x in range(len(self.matCarre[0])):
                self.matCarre[y][x].afficher(self.grille, x, y)


    #infecte la case lorsqu'on clique gauche dessus
    def infecter(self, event):
        x = event.x - (event.x%self.tailleCellule)
        y = event.y - (event.y%self.tailleCellule)

        i = int(x/self.tailleCellule)
        j = int(y/self.tailleCellule)

        if(self.matCarre[j][i].etat == "sain"):
            self.matCarre[j][i].setEtat("infecte")
            self.matCarre[j][i].afficher(self.grille, i, j)
            print("la cellule " + repr(i) + " ; " + repr(j) + " a été infectée.")
            self.nbSain = self.nbSain - 1
            self.nbInfecte = self.nbInfecte + 1

    #soigne la case lorsqu'on clique droit dessus
    def guerir(self, event):
        x = event.x -(event.x%self.tailleCellule)
        y = event.y -(event.y%self.tailleCellule)

        i = int(x/self.tailleCellule)
        j = int(y/self.tailleCellule)

        if(self.matCarre[j][i].etat == "infecte"):
            self.matCarre[j][i].setEtat("sain")
            self.matCarre[j][i].afficher(self.grille, i, j)
            print("la cellule " + repr(i) + " ; " + repr(j) + " a été guérie.")
            self.nbSain = self.nbSain + 1
            self.nbInfecte = self.nbInfecte - 1

    def propagerTauxReproduction (self, matDeTest,posX, posY):

        tauxInfection = 0.0
        # 01 02 03 04 05 #
        # 06 07 08 09 10 #
        # 11 12 XX 13 14 #
        # 15 16 17 18 19 #
        # 20 21 22 23 24 #

        #Récupère le nombre de case inféctées pour chaque case et ajoute si c'est le cas un taux.
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
            #Defini si la case devient infectée
            nbAlea = randint(0,100)
            if (nbAlea < tauxInfection*self.virus.tauxReproduction):
                self.matCarre[posY][posX].setEtat("infecte")
                self.matCarre[posY][posX].afficher(self.grille, posX, posY)
                self.nbSain = self.nbSain - 1
                self.nbInfecte = self.nbInfecte + 1

    #Propage le virus jour par jour 
    def propager (self):
        matDeTest = copy.deepcopy(self.matCarre)
        for y in range(self.nbCelluleHauteur):
            for x in range(self.nbCelluleLargeur):
                if (self.matCarre[y][x].etat == "sain"):
                    self.propagerTauxReproduction(matDeTest, x, y)

    #Propage le virus d'un jour                
    def propagerUneFois (self, event):
        self.propager();


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

#END Grille

##### MAIN #####

#Création de la fenêtre
root = Tk()
root.title('Propagation virus')

#Création compteur de jour
compteur = Label(root, text="Jour 0")
compteur.pack()

#Création % inféctées
pctInfecte = Label(root, text="Infecte : 0%")
pctInfecte.pack()

#Création de la grille représentative de la population
#Paramètres = Taille en pixel, largeur, longueur, virus, nb de personne dans un carré
grille = Grille(root.winfo_screenheight(), root.winfo_screenwidth(), 100, 100, Virus("Peste noire"), 5)
grille.afficher()

#Création d'un thread pour la propagation
thread = MonThread(grille, compteur)
thread.start()

root.protocol("WM_DELETE_WINDOW", thread.stop)

#Creation des boutons
boutonStart = Button(root, text="Start", command=thread.continu)
boutonStart.pack()
boutonPause = Button(root, text="Pause", command=thread.pause)
boutonPause.pack()
boutonStop = Button(root, text="Stop", command=thread.stop)
boutonStop.pack()

#Lancement de la fenêtre
root.mainloop()