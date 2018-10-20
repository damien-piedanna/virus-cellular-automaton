# -*- cod# -*- coding: utf-8 -*-
###############################################################################################
#
# Ce fichier contient toutes les fonctions du projet qui ne sont pas des méthodes d'une classe
#
###############################################################################################

from classes.cellule import Position
from classes.elementsGrille import Deplacement

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