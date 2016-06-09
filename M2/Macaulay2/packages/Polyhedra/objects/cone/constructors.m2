-- Defining the new type Cone
Cone = new Type of PolyhedralObject
Cone.synonym = "convex rational cone"
globalAssignment Cone
compute#Cone = new MutableHashTable

Cone == Cone := (C1,C2) -> (
   contains(C1, C2) and contains(C2, C1)
)


cone HashTable := inputProperties -> (
   constructTypeFromHash(Cone, inputProperties)
)


coneFromRayData = method(TypicalValue => Cone)
coneFromRayData(Matrix, Matrix) := (iRays, linealityGenerators) -> (
     -- checking for input errors
     if numRows iRays =!= numRows linealityGenerators then error("rays and linSpace generators must lie in the same space");
     result := new HashTable from {
         ambientDimension => numRows iRays,
         computedRays => iRays,
         computedLinealityBasis => linealityGenerators
     };
     cone result
)


coneFromFacetData = method(TypicalValue => Cone)
coneFromFacetData(Matrix, Matrix) := (ineq, eq) -> (
   if numColumns ineq =!= numColumns eq then error("facets and hyperplanes must lie in same space");
   result := new HashTable from {
      ambientDimension => numColumns ineq,
      computedFacets => ineq,
      computedHyperplanes => eq
   };
   cone result
)


-- PURPOSE : Computing the positive hull of a given set of rays lineality 
--		 space generators
posHull = method(TypicalValue => Cone)

--   INPUT : 'Mrays'  a Matrix containing the generating rays as column vectors
--		 'LS'  a Matrix containing the generating rays of the 
--				lineality space as column vectors
--  OUTPUT : 'C'  a Cone
-- COMMENT : The description by rays and lineality space is stored in C as well 
--		 as the description by defining half-spaces and hyperplanes.
posHull(Matrix,Matrix) := (Mrays,LS) -> (
   if numRows Mrays =!= numRows LS then error("rays and linSpace generators must lie in the same space");
   result := new Cone from {
      ambientDimension => numRows Mrays,
      inputRays => Mrays,
      inputLinealityGenerators => LS
   };
   cone result
)

--   INPUT : 'M',  a matrix, such that the Cone is given by C={x | Mx>=0} 
--  OUTPUT : 'C', the Cone
intersection Matrix := M -> (
   r := ring M;
   N := transpose map(source M, r^0, 0); 
   intersection(M, N)
)




--   INPUT : 'R'  a Matrix containing the generating rays as column vectors
posHull Matrix := R -> (
   r := ring R;
   -- Generating the zero lineality space LS
   LS := map(target R, r^0,0);
   posHull(R,LS)
)


--   INPUT : '(C1,C2)'  two cones
posHull(Cone,Cone) := (C1,C2) -> (
   local iRays;
   local linealityGens;
   if hasProperties(C1, {computedRays, computedLinealityBasis}) then (
      iRays = rays C1;
      linealityGens = linealitySpace C1;
   ) else if hasProperties(C1, {inputRays, inputLinealityGenerators}) then (
      iRays = getProperty(C1, inputRays);
      linealityGens = getProperty(C1, inputLinealityGenerators);
   ) else (
      iRays = rays C1;
      linealityGens = linealitySpace C1;
   );
   if hasProperties(C2, {computedRays, computedLinealityBasis}) then (
      iRays = iRays | rays C2;
      linealityGens = linealityGens | linealitySpace C2;
   ) else if hasProperties(C2, {inputRays, inputLinealityGenerators}) then (
      iRays = iRays | getProperty(C2, inputRays);
      linealityGens = linealityGens | getProperty(C2, inputLinealityGenerators);
   ) else (
      iRays = iRays | rays C2;
      linealityGens = linealityGens | linealitySpace C2;
   );
   posHull(iRays, linealityGens)
)


--   INPUT : 'L',   a list of Cones, Polyhedra, rays given by R, 
--     	    	    and (rays,linSpace) given by '(R,LS)'
posHull List := L -> (
   -- Turn everything into cones.
   cones := apply(L, 
      l -> (
         if not instance(l, Cone) then posHull l
         else l
      )
   );
   result := cones#0;
   cones = remove(cones, 0);
   -- Adding the cones is not expensive, since we will not do fourierMotzkin
   -- every time.
   for cone in cones do (
      result = posHull(result, cone);
   );
   result
)
