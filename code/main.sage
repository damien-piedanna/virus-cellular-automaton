# -*- coding: utf-8 -*-

#https://fr.statista.com/statistiques/472349/repartition-population-groupe-dage-france/


from tkinter import *
from random import *
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
            self.contagiosite = 99
        else:
            self.contagiosite = 5



class Grille:
    def __init__(self, hauteurPx, nbCelluleHauteur, nbCelluleLargeur, virus, nbPers):

        self.nbCelluleHauteur = nbCelluleHauteur
        self.nbCelluleLargeur = nbCelluleLargeur

        self.tailleCellule = int(hauteurPx/nbCelluleHauteur)
        if (nbCelluleLargeur*self.tailleCellule > 1920):
            self.tailleCellule = int(1920/nbCelluleLargeur)

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
        #Création des carrés qui compose la grile et les range dans une matrice.
        for i in range (0, nbCelluleHauteur):
            ligne = []
            for j in range (0, nbCelluleLargeur):
                if(randint(0, 1)):
                    ligne.append(Carre(self.tailleCellule, "vide"))
                else:
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

                    ageMoy = round(ageMoy/nbPers)

                    ligne.append(CarrePopulation(self.tailleCellule, "sain", ageMoy))
                    print(ageMoy);
                    self.nbSain = self.nbSain + 1
            self.matCarre.append(ligne)
                
    def afficher(self):
        for y in range(self.nbCelluleHauteur):
            for x in range(self.nbCelluleLargeur):
                self.matCarre[y][x].afficher(self.grille, x, y)



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

    def uneFonction (self, matDeTest,posX, posY):
        nbCasesAdjInfec = 0

        if (posY > 0 and posX > 0 and posY < self.nbCelluleHauteur and posX < self.nbCelluleLargeur and matDeTest[posY-1][posX-1].etat == "infecte"):
            nbCasesAdjInfec = nbCasesAdjInfec + 1
        if (posY > 0 and posY < self.nbCelluleHauteur and posX < self.nbCelluleLargeur and matDeTest[posY-1][posX].etat == "infecte"):
            nbCasesAdjInfec = nbCasesAdjInfec + 1
        if (posY > 0 and posY < self.nbCelluleHauteur and posX < self.nbCelluleLargeur-1 and matDeTest[posY-1][posX+1].etat == "infecte"):
            nbCasesAdjInfec = nbCasesAdjInfec + 1
        if (posX > 0 and posY < self.nbCelluleHauteur and posX < self.nbCelluleLargeur and matDeTest[posY][posX-1].etat == "infecte"):
            nbCasesAdjInfec = nbCasesAdjInfec + 1
        if (posX > 0 and posY < self.nbCelluleHauteur and posX < self.nbCelluleLargeur-1 and matDeTest[posY][posX+1].etat == "infecte"):
            nbCasesAdjInfec = nbCasesAdjInfec + 1
        if (posX > 0 and posY < self.nbCelluleHauteur-1 and posX < self.nbCelluleLargeur and matDeTest[posY+1][posX-1].etat == "infecte"):
            nbCasesAdjInfec = nbCasesAdjInfec + 1
        if (posY < self.nbCelluleHauteur-1 and posX < self.nbCelluleLargeur and matDeTest[posY+1][posX].etat == "infecte"):
            nbCasesAdjInfec = nbCasesAdjInfec + 1
        if (posY < self.nbCelluleHauteur-1 and posX < self.nbCelluleLargeur-1 and matDeTest[posY+1][posX+1].etat == "infecte"):
            nbCasesAdjInfec = nbCasesAdjInfec + 1

        if (nbCasesAdjInfec > 0):
            #print(repr(nbCasesAdjInfec) + " cellules infectées autour de " + repr(posX) + " ; " + repr(posY))

            nbAlea = randint(0,100)
            if (nbAlea < nbCasesAdjInfec*self.virus.contagiosite):
                self.matCarre[posY][posX].setEtat("infecte")
                self.matCarre[posY][posX].afficher(self.grille, posX, posY)
                print("la cellule " + repr(posX) + " ; " + repr(posY) + " a été infectée.")
                self.nbSain = self.nbSain - 1
                self.nbInfecte = self.nbInfecte + 1

                if (matDeTest == self.matCarre):
                    print 'cest chiant'


    def propager (self):
        matDeTest = copy.deepcopy(self.matCarre)
        for y in range(self.nbCelluleHauteur):
            for x in range(self.nbCelluleLargeur):
                if (self.matCarre[y][x].etat == "sain"):
                    self.uneFonction(matDeTest, x, y)


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
            time.sleep (1)
            grille.propager()
            cpt = cpt +1
            compteur.config(text="Jour " + repr(cpt))
            pct = int(grille.nbInfecte*100/(grille.nbInfecte + grille.nbSain))
            pctInfecte.config(text="Infectes: " + repr(pct) + "%")

 
    def stop(self):
        self._etat = False
        sys.exit("Arrêt du programme...")
 
    def pause(self):
        self._pause = True
 
    def continu(self):
        self._pause = False

#END Grille

##### MAIN #####

root = Tk()
root.title('Propagation virus')


compteur = Label(root, text="Jour 0")
compteur.pack()

pctInfecte = Label(root, text="Infecte : 0%")
pctInfecte.pack()

grille = Grille(850, 50, 50, Virus("Peste noire"), 5)
grille.afficher()

thread = MonThread(grille, compteur)
thread.start()

boutonStart = Button(root, text="Start", command=thread.continu)
boutonStart.pack()
boutonPause = Button(root, text="Pause", command=thread.pause)
boutonPause.pack()
boutonStop = Button(root, text="Stop", command=thread.stop)
boutonStop.pack()

root.mainloop()