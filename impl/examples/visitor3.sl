--> "((5.0 - (2.0 + 3.0)) + 3.0) = 3.0"

type ExpAlg[E] = {
  lit : Double -> E,
  add : E -> E -> E
};

type Exp = { accept : forall E . ExpAlg[E] -> E };

type IEval = { eval : Double };

trait evalAlg  => {
  lit (x : Double)   = { eval = x };
  add (x : IEval) (y : IEval) = { eval = x.eval + y.eval }
} : ExpAlg[IEval];


type SubExpAlg[E] = ExpAlg[E] & { sub : E -> E -> E };
trait subEvalAlg   inherits evalAlg  => {
  sub (x : IEval) (y : IEval) = { eval = x.eval - y.eval }
} : SubExpAlg[IEval];
type ExtExp = { accept: forall E. SubExpAlg[E] -> E };



type IPrint = { print : String };


trait printAlg [ self : Top ] => {
  lit (x : Double)   = { print = x.toString };
  add (x : IPrint) (y : IPrint) = { print = "(" ++ x.print ++ " + " ++ y.print ++ ")" };
  sub (x : IPrint) (y : IPrint) = { print = "(" ++ x.print ++ " - " ++ y.print ++ ")" }
} : SubExpAlg[IPrint];



lit (n : Double) : Exp = {
  accept E f = f.lit n
};
add (e1 : Exp) (e2 : Exp) : Exp = {
  accept E f = f.add (e1.accept E f) (e2.accept E f)
};
sub (e1 : ExtExp) (e2 : ExtExp) : ExtExp = {
  accept E f = f.sub (e1.accept E f) (e2.accept E f)
};



-- BEGIN_COMBINE_DEF
combine A [B * A] (f : Trait[Top, SubExpAlg[A]]) (g : Trait[Top, SubExpAlg[B]]) = trait  inherits f & g => { };
-- END_COMBINE_DEF

e1 : Exp = {accept E f = f.add (f.lit 2) (f.lit 3)};
e2 : ExtExp = { accept E f = f.sub (f.lit 5) (e1.accept E f) };
e3 : ExtExp = { accept E f = f.add (e2.accept E f) (f.lit 3) };

-- BEGIN_COMBINE1_TEST
alg = combine IEval IPrint subEvalAlg printAlg;
o = e3.accept (IEval & IPrint) (new[SubExpAlg[IEval & IPrint]] alg);
main = o.print ++ " = " ++ o.eval.toString
-- Output: "((5.0 - (2.0 + 3.0)) + 3.0) = 3.0"
-- END_COMBINE1_TEST
