/* #1 Donner la liste des produits de type "Bien-être" avec leur quantité disponible en stock */
SELECT NomProd, QuantiteStock
FROM Produits
WHERE LibelleType = 'Bien-être';

/* #2 Donner la liste des clients et nombre de commandes enregistrées à leur nom. */
SELECT Cl.IdCl, NomCl, PrenomCl, COUNT(NumCmd)
FROM Clients Cl LEFT JOIN Commandes Cmd ON Cl.IdCl = Cmd.IdCl
GROUP BY Cl.IdCl, NomCl, PrenomCl;

/* #3 Lister les commandes non finalisée avec le numéro et nom du client et le numéro et nom du conseiller choisi. */
SELECT NumCmd, Cmd.IdCl, NomCl, Cmd.IdCons, NomCons
FROM (Commandes Cmd JOIN Clients Cl ON Cmd.IdCl = Cl.IdCl)
	JOIN Conseillers Cons ON Cmd.IdCons = Cons.IdCons
WHERE EtatCmd = "En attente de validation";

/* #4 Donner la liste des points relais localisés en Charente-Maritime (17) avec leur adresse complète. */
SELECT IdRel, NomRel, NumRueRel, NomRueRel, CPRel, Ville, PaysRel
FROM PointsRelais Rel JOIN CodesPostaux CP ON Rel.CPRel = CP.CP
WHERE Rel.CPRel >= 17000 AND Rel.CPRel < 18000;

/* #5 Lister les clients participant au programme de fidélité */ 
CREATE VIEW ProgFidelite
AS
	SELECT * 
	FROM Clients
	WHERE DateAdhCl IS NOT NULL;

SELECT IdCl, NomCl, PrenomCl
FROM ProgFidelite;

/* #6 Donner le nom des clients faisant partie du programme de fidélité depuis plus d'1 an. */
SELECT IdCl, NomCl, PrenomCl
FROM ProgFidelite
WHERE DATEDIFF(CURDATE(), DateAdhCl) > 365;

/* #7 Donner le nombre de bons d'achat émis, le montant total de ces bons. */
SELECT COUNT(NumBon) NbBonsEmis, SUM(MontantBon) MontantTotal
FROM BonsAchats;

/* #8 Donner le nombre de bons d'achat utilisés ainsi que le montant total de ces bons. */
SELECT COUNT(NumBon) NbBonsUtilises, SUM(MontantBon) MontantTotal
FROM BonsAchats
WHERE NumCmd IS NOT NULL;

/* #9 Donner la quantité de produits commandés dans chaque catégorie pour chaque client. */ 
CREATE VIEW Interets
AS
	SELECT Cmd.IdCl, Prod.LibelleType, SUM(QuantiteVoulue) ProdCommandes
	FROM (CompositionCmd Comp JOIN Produits Prod ON Comp.IdProd = Prod.IdProd)
		JOIN Commandes Cmd ON Comp.NumCmd = Cmd.NumCmd
	GROUP BY Cmd.IdCl, Prod.LibelleType;
	
SELECT *
FROM Interets;

/* #10 Pour les clients faisant partie du programme de fidélité, donner l'âge moyen des clients. */
SELECT ROUND(AVG(DATEDIFF(CURDATE(),DateNaisCl)/365)) AgeMoyen
FROM ProgFidelite;

/* #11 Pour le client n°17925867, donner son âge, sa date de naissance et la catégorie de produit qui l'intéresse le plus (le plus de produits commandés). */
SELECT NomCl, PrenomCl, DateNaisCl, ROUND(DATEDIFF(CURDATE(),DateNaisCl)/365) Age, I.LibelleType
FROM Clients Cl JOIN Interets I ON Cl.IdCl = I.IdCl
WHERE Cl.IdCl = 17925867 AND ProdCommandes = (SELECT MAX(ProdCommandes)
						FROM Interets
						WHERE Cl.IdCl = 17925867);

/* #12 Lister tous les produits de la gamme "anti-âge" */ 
SELECT *
FROM Produits
WHERE NomProd LIKE '%anti-âge%';

/* #13 Lister les clients ayant dépensé de l'argent les 2 dernier mois, avec le montant dépensé. */
SELECT IdCl, SUM(PrixTotCmd) MontantDepense
FROM Commandes 
WHERE NumCmd IN (SELECT NumCmd
				FROM Commandes
				WHERE DATEDIFF(CURDATE(), DateCmd) < 2*365)
GROUP BY IdCl;

/* #14 Donner le montant du panier moyen */
SELECT AVG(PrixTotCmd) PanierMoyen
FROM Commandes;

/* #15 Donner le nom des clients ayant dépensé au total plus de 80 euros. */
SELECT Cmd.IdCl, NomCl, PrenomCl, SUM(PrixTotCmd)
FROM Commandes Cmd JOIN Clients Cl ON Cmd.IdCl = Cl.IdCl
GROUP BY Cmd.IdCl, NomCl, PrenomCl
HAVING SUM(PrixTotCmd) > 80;

/* #16 Donner le produit le plus commandé et la quantité écoulée. */
CREATE VIEW Ventes
AS
	SELECT IdProd, SUM(QuantiteVoulue) QuantiteVendue
	FROM CompositionCmd
	GROUP BY IdProd;
	
SELECT V.IdProd, NomProd, QuantiteVendue
FROM Ventes V JOIN Produits Prod ON V.IdProd = Prod.IdProd
WHERE QuantiteVendue = (SELECT MAX(QuantiteVendue)
						FROM Ventes);

/* #17 Lister les produits qui n'ont jamais été commandés. */ 
SELECT IdProd, NomProd
FROM Produits
WHERE IdProd NOT IN (SELECT DISTINCT IdProd
					FROM CompositionCmd);


/* Facture */ 
/* #18 Pour la commande n° 14695372, donner l'adresse complète du client */ 
SELECT NomCl, PrenomCl, NumRueCL, NomrueCl, CPCl, Ville, PaysCl 
FROM Clients CL JOIN CodesPostaux CP ON Cl.CPCl = CP.CP
WHERE IdCl = (SELECT IdCl
				FROM Commandes
				WHERE NumCmd = 14695372);

/* #19 Pour la commande n°14695372, lister les produits commandés, la quantité voulue pour chaque produit, leur prix hors-taxe et le prix TTC */
SELECT Comp.IdProd, NomProd, PrixHT, PrixHT*(1 + Taxe) PrixTTC
FROM (CompositionCmd Comp JOIN Produits Prod ON Comp.IdProd = Prod.IdProd)
		JOIN Types T ON Prod.LibelleType = T.LibelleType
WHERE NumCmd = 14695372;

/* #20 Pour la commande n°14695372, donner le numéro de la facture, la date de la facture, le prix total de la commande, le prix des frais de port ainsi que l'adresse du point relais */  
SELECT F.NumCmd, NumFac, DateFac, PrixTotCmd, FdP, NomRel, NumRueRel, NomRueRel, CPRel, Ville, PaysRel
FROM (((Factures F JOIN Commandes Cmd ON F.NumCmd = Cmd.NumCmd)
		JOIN PointsRelais Rel ON Cmd.IdRel = Rel.IdRel)
		JOIN CodesPostaux CP ON Rel.CPRel = CP.CP)
		JOIN FraisDePort Frais ON Rel.PaysRel = Frais.PaysRel
WHERE F.NumCmd = 14695372;

