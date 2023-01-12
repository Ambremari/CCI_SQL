DELIMITER $$
CREATE FUNCTION bodynature.calculTotal(myNum decimal(8))
RETURNS decimal(6,2)
BEGIN 
	RETURN (SELECT SUM(QuantiteVoulue*PrixHT*(1+Taxe))
			FROM (CompositionCmd Comp JOIN Produits P 
				ON Comp.IdProd = P.IdProd) JOIN 
				Types T ON P.LibelleType = T.LibelleType
			WHERE NumCmd = myNum);
END;
$$
DELIMITER ;	
