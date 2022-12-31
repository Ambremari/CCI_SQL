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
  CP decimal(5)
CONSTRAINT PK_CodesPostaux PRIMARY KEY,
  Ville Char Varying(20) 
);

CREATE TABLE FraisDePort(
  PaysRel Char Varying(20)
CONSTRAINT PK_FraisDePort PRIMARY KEY,
  FdP decimal(2)
);

CREATE TABLE Conseillers(
  IdCons decimal(8)
CONSTRAINT PK_Conseillers PRIMARY KEY,
  NomCons Char Varying(20) NOT NULL,
  PrenomCons Char Varying(20) NOT NULL
);
  
CREATE TABLE Types(
  LibelleType Char Varying(20)
CONSTRAINT PK_Types PRIMARY KEY,
  Taxe decimal(3,2)
CONSTRAINT Dom_Taxe CHECK (Taxe > 0 AND Taxe < 1)
);

CREATE TABLE Produits(
  IdProd decimal(8)
CONSTRAINT PK_Produits PRIMARY KEY,
  NomProd Char Varying(100) NOT NULL,
  PrixHT decimal(4),
  QuantiteStock decimal(6),
  LibelleType Char Varying(20)
CONSTRAINT FK_Prod_ref_Types REFERENCES Types(LibelleType),
);

CREATE TABLE PointsRelais(
  IdRel decimal(8)
CONSTRAINT PK_PointsRelais PRIMARY KEY,
  NomRel Char Varying(50) NOT NULL,
  NumRueRel decimal(4),
  NomRueRel Char Varying(50),
  CPRel decimal(5)
CONSTRAINT FK_Rel_ref_CodesPostaux REFERENCES CodesPostaux(CP),
  PaysRel Char Varying(20)
CONSTRAINT FK_Rel_ref_FraisDePort REFERENCES FraisDePort(PaysRel),
);

CREATE TABLE Clients(
  IdCl decimal(8)
CONSTRAINT PK_Clients PRIMARY KEY,
  NomCl Char Varying(20) NOT NULL,
  PrenomCl Char Varying(20) NOT NULL,
  NumRueCl decimal(4),
  NomRueCl Char Varying(50),
  PaysCl Char Varying(20),
  MailCl Char Varying(50)
CONSTRAINT Dom_MailCl CHECK (MailCl LIKE (".*@.*\..*")),
  TelCl Char(10),
CONSTRAINT Dom_TelCl CHECK (TelCl LIKE("0{0,9}*"),
  PointsFid decimal(4),
  DateNaisCl Date
CONSTRAINT Dom_DateNaisCl CHECK (DateNaisCl > '1900-01-01'),
  DateAdhCl Date
CONSTRAINT Dom_DateAdhCl CHECK (DateCmd > '2000-01-01'),
  CPCl decimal(5)
CONSTRAINT FK_Cl_ref_CodesPostaux REFERENCES CodesPostaux(CP),
);

CREATE TABLE Commandes(
  NumCmd decimal(8)
CONSTRAINT PK_Commandes PRIMARY KEY,
  DateCmd Date
CONSTRAINT Dom_DateCmd CHECK (DateCmd > '2000-01-01')
  EtatCmd Char Varying(30) NOT NULL DEFAULT "En attente de validation" CONSTRAINT Dom_EtatCmd CHECK (EtatCmd IN("En attente de validation", "Payée, en attente de préparation", "En préparation", "Expédiée", "En point relais", "Finalisée"), 
  DateLiv Date
CONSTRAINT Dom_DateLiv CHECK (DateLiv > DateCmd),
  PrixTotCmd decimal(4),
  IdCl decimal(8)
CONSTRAINT FK_Cmd_ref_Cl REFERENCES Clients(IdCl),
  IdCons decimal(8)
CONSTRAINT FK_Cmd_ref_Cons REFERENCES Conseillers(IdCons),
  IdRel decimal(8)
CONSTRAINT FK_Cmd_ref_Rel REFERENCES PointsRelais(IdRel),
);

CREATE TABLE BonsAchats(
  NumBon decimal(8)
CONSTRAINT PK_BonsAchats PRIMARY KEY,
  DateEmis Date,
  MontantBon decimal(2) DEFAULT 10,
  IdCl decimal(8)
CONSTRAINT FK_BonsAch_ref_Cl REFERENCES Clients(IdCl),
  NumCmd decimal(8)
CONSTRAINT FK_BonsAch_ref_Cmd REFERENCES Commandes(NumCmd),
);

CREATE TABLE Factures(
  NumFac decimal(8)
CONSTRAINT PK_Factures PRIMARY KEY,
  DateFac Date
CONSTRAINT Dom_DateFac CHECK (DateFac > DateCmd),,
  NumCmd decimal(8)
CONSTRAINT FK_Fac_ref_Cmd REFERENCES Commandes(NumCmd),
);

CREATE TABLE CompositionCmd(
  NumCmd decimal(8)
CONSTRAINT FK_Compo_ref_Cmd REFERENCES Commandes(NumCmd),
  IdProd decimal(8)
CONSTRAINT FK_Compo_ref_Prod REFERENCES Produits(IdProd),
  QuantiteVoulue decimal(3),
CONSTRAINT PK_CompositionCmd PRIMARY KEY(NumCmd,IdProd)
);




