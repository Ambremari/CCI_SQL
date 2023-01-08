DROP TABLE CompositionCmd;
DROP TABLE Factures;
DROP TABLE BonsAchats;
DROP TABLE Commandes;
DROP TABLE Clients;
DROP TABLE PointsRelais;
DROP TABLE Produits;
DROP TABLE Types;
DROP TABLE Conseillers;
DROP TABLE FraisDePort;
DROP TABLE CodesPostaux;

CREATE TABLE CodesPostaux(
  CP decimal(5) NOT NULL,
  Ville Char Varying(20),
  CONSTRAINT PK_CodesPostaux PRIMARY KEY (CP)
);

CREATE TABLE FraisDePort(
  PaysRel Char Varying(20) NOT NULL,
  FdP decimal(2),
  CONSTRAINT PK_FraisDePort PRIMARY KEY (PaysRel)
);

CREATE TABLE Conseillers(
  IdCons decimal(8) NOT NULL,
  NomCons Char Varying(20) NOT NULL,
  PrenomCons Char Varying(20) NOT NULL,
  CONSTRAINT PK_Conseillers PRIMARY KEY (IdCons)
);
  
CREATE TABLE Types(
  LibelleType Char Varying(20) NOT NULL,
  Taxe decimal(3,2)
	CHECK (Taxe > 0 AND Taxe < 1),
  CONSTRAINT PK_Types PRIMARY KEY (LibelleType)
);

CREATE TABLE Produits(
  IdProd decimal(8) NOT NULL,
  NomProd Char Varying(100) NOT NULL,
  PrixHT decimal(4),
  QuantiteStock decimal(6),
  LibelleType Char Varying(20)
	CONSTRAINT FK_Prod_ref_Types
	REFERENCES Types(LibelleType),
  CONSTRAINT PK_Produits PRIMARY KEY (IdProd)
);

CREATE TABLE PointsRelais(
  IdRel decimal(8) NOT NULL,
  NomRel Char Varying(50) NOT NULL,
  NumRueRel decimal(4),
  NomRueRel Char Varying(50),
  CPRel decimal(5)
	CONSTRAINT FK_Rel_ref_CodesPostaux 
	REFERENCES CodesPostaux(CP),
  PaysRel Char Varying(20)
	CONSTRAINT FK_Rel_ref_FraisDePort
	REFERENCES FraisDePort(PaysRel),
  CONSTRAINT PK_PointsRelais PRIMARY KEY (IdRel)
);

CREATE TABLE Clients(
  IdCl decimal(8) NOT NULL,
  NomCl Char Varying(20) NOT NULL,
  PrenomCl Char Varying(20) NOT NULL,
  NumRueCl decimal(4),
  NomRueCl Char Varying(50),
  PaysCl Char Varying(20),
  MailCl Char Varying(50)
	CHECK (MailCl LIKE (".*@.*\..*")),
  TelCl Char(10)
	CHECK (TelCl LIKE ("0{0,9}*")),
  PointsFid decimal(4),
  DateNaisCl Date
	CHECK (DateNaisCl > '1900-01-01'),
  DateAdhCl Date
	CHECK (DateAdhCl > '2000-01-01'),
  CPCl decimal(5) 
	CONSTRAINT FK_Cl_ref_CodesPostaux 
	REFERENCES CodesPostaux(CP),
  CONSTRAINT PK_Clients PRIMARY KEY (IdCl)
);

CREATE TABLE Commandes(
  NumCmd decimal(8) NOT NULL,
  DateCmd Date
	CHECK (DateCmd > '2000-01-01'),
  EtatCmd Char Varying(30) NOT NULL 
	DEFAULT "En attente de validation" 
	CHECK (EtatCmd IN("En attente de validation", 
					"Payée, en attente de préparation", 
					"En préparation", 
					"Expédiée", 
					"En point relais", 
					"Finalisée")), 
  DateLiv Date,
  PrixTotCmd decimal(4),
  IdCl decimal(8)
	CONSTRAINT FK_Cmd_ref_Cl
	REFERENCES Clients(IdCl),
  IdCons decimal(8)
	CONSTRAINT FK_Cmd_ref_Cons
	REFERENCES Conseillers(IdCons),
  IdRel decimal(8)
	CONSTRAINT FK_Cmd_ref_Rel
	REFERENCES PointsRelais(IdRel),
  CONSTRAINT PK_Commandes PRIMARY KEY (NumCmd),
  CONSTRAINT Ordre_date CHECK (DateLiv > DateCmd)
);

CREATE TABLE BonsAchats(
  NumBon decimal(8) NOT NULL,
  DateEmis Date,
  MontantBon decimal(2) DEFAULT 10,
  IdCl decimal(8)
	CONSTRAINT FK_BonsAch_ref_Cl
	REFERENCES Clients(IdCl),
  NumCmd decimal(8) 
	CONSTRAINT FK_BonsAch_ref_Cmd
	REFERENCES Commandes(NumCmd),
  CONSTRAINT PK_BonsAchats PRIMARY KEY (NumBon)
);

CREATE TABLE Factures(
  NumFac decimal(8) NOT NULL,
  DateFac Date,
  NumCmd decimal(8)
	CONSTRAINT FK_Fac_ref_Cmd
	REFERENCES Commandes(NumCmd),
  CONSTRAINT PK_Factures PRIMARY KEY (NumFac)
);

CREATE TABLE CompositionCmd(
  NumCmd decimal(8) NOT NULL
	CONSTRAINT FK_Compo_ref_Cmd
	REFERENCES Commandes(NumCmd),
  IdProd decimal(8) NOT NULL
	CONSTRAINT FK_Compo_ref_Prod
	REFERENCES Produits(IdProd),
  QuantiteVoulue decimal(3),
  CONSTRAINT PK_CompositionCmd PRIMARY KEY(NumCmd,IdProd)
);

/* ALTER TABLE Factures
ADD  CONSTRAINT Dom_DateFac 
CHECK (bodynature.checkDate(NumCmd, DateFac) = 1); */

DELIMITER $$
CREATE FUNCTION bodynature.checkDate(myNum decimal(8), myDate Date)
RETURNS INT
BEGIN 
	IF myDate > (SELECT DateCmd
				FROM Commandes
				WHERE NumCmd = myNum)
	THEN
		RETURN 	1;
	ELSE
		RETURN 0;
	END IF;
END;
$$
DELIMITER ;	




