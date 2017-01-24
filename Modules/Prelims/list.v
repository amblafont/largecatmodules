Require Import UniMath.Foundations.PartD.
Require Import UniMath.Foundations.Propositions.
Require Import UniMath.Foundations.Sets.

Require Import UniMath.CategoryTheory.precategories.
Require Import UniMath.CategoryTheory.functor_categories.
Require Import UniMath.CategoryTheory.UnicodeNotations.


Require Import UniMath.CategoryTheory.limits.initial.
Require Import UniMath.CategoryTheory.limits.graphs.equalizers.
Require Import UniMath.Combinatorics.StandardFiniteSets.
Require Import UniMath.CategoryTheory.Epis.
Require Import UniMath.CategoryTheory.category_hset.
Require Import UniMath.CategoryTheory.category_hset_structures.

Fixpoint itern (F0:UU) (F : UU -> UU) (n:nat) : UU :=
  match n with
    0 => F0
  | S p => F (itern F0 F p)
  end.


Module List1.

  Definition puissancen (A:UU) (n:nat) : UU := itern unit (fun B => A × B) n.


Definition List : UU := Σ n, puissancen nat n.

Definition nil : List := (0 ,, tt).

Definition cons (a:nat) (l:List): List.
  use tpair.
  exact (S (pr1 l)).
  cbn.
  use tpair.
  exact a.
  exact (pr2 l).
Defined.

(** The induction principle for lists defined using foldr *)
Section list_induction.

Variables (P : List -> UU) (PhSet : Π l, isaset (P l)).
Variables (P0 : P nil)
          (Pc : Π a l, P l -> P (cons a l)).

Lemma final (l:List) : P l.
  destruct l as [n l].
  induction n.
  - destruct l.
  exact P0.
  - specialize (IHn (pr2 l)).
    assert(yop:= Pc (pr1 l) (n,,pr2 l) IHn).
    unfold cons in yop.
    cbn in yop.
    now destruct l.
Defined.

Lemma fnil : final nil = P0.
  apply idpath.
Qed.

Lemma fcons a l : final (cons a l) = Pc a l (final l).
  (* il faut d'abord détruire l pour avoir la réduction *)
  destruct l.
  apply idpath.
Qed.
End list_induction.


Definition length (l:List) := final (fun _ => nat) 0 (fun _ _ n => S n) l.

Eval compute in (length nil).

End List1.

Module List2.
  Open Scope stn.
  Section def.
    (* Variable (TT : UU). *)
    Local Notation TT := nat.
  Definition One : two := ● 0.
  Definition Two : two := ● 1.

  Definition sum (A:UU) (B:UU) := Σ (x:two), two_rec (A:=UU) A B x.

  (* à base de quotient *)
  Definition F (A:UU) :UU := sum unit (TT×A).

  Definition Listn (n:nat) := itern ∅ F n.

  Definition Fmor1 {A B:UU} (C:UU) (f: A -> B) (x:sum C A) : sum C B.
    use tpair.
   exact (pr1 x).
   generalize (pr2 x).
    use (two_rec_dep (fun a => two_rec C A a -> two_rec C B a) _ _ (pr1 x));cbn.
    apply idfun.
    exact f.
  Defined.

  Definition Fmor {A B:UU} (f:A -> B) : F A -> F B.
    apply Fmor1.
    intro x.
    exact (pr1 x,, f (pr2 x)).
  Defined. 

  Definition injF {n} (l:Listn n) : Listn (S n).
    induction n.
    now apply Empty_set_rect.
    revert IHn l.
    apply Fmor.
  Defined.


  Definition list_rel {p q:nat} (l:Listn p) (l':Listn q): UU.
    set (h:= isdeceqnat q (S p) ).
    cbn in h.
    use (coprod_rect (fun _ => UU) _ _ h).
    - intro heq.
      cbn.
      clear h.
      rewrite heq in l'.
      exact (l' = injF l).
    - intros.
      exact Empty_set.
      Qed.
  (* Defined. *)

  Definition Chain := Σ n, Listn n.

  Lemma myisapropishinh :Π X : UU, isaprop (ishinh_UU X).
    exact isapropishinh.
  Qed.
  Lemma myisasetsetquot: Π (X : UU) (R : hrel X), isaset (setquot R).
    exact @isasetsetquot.
  Qed.

  (* copié de category_hset_structure *)
(* Theory about hprop is in UniMath.Foundations.Propositions *)
Local Definition rel0 : hrel Chain := λ (ia jb : Chain),
  hProppair (ishinh (list_rel (pr2 ia) (pr2 jb)))
            (myisapropishinh _).

Local Definition rel : hrel Chain := eqrel_from_hrel rel0.
Lemma iseqrel_rel : iseqrel rel.
Proof.
now apply iseqrel_eqrel_from_hrel.
Qed.

Local Definition eqr : eqrel Chain := eqrelpair _ iseqrel_rel.

Definition List : hSet :=
  hSetpair (setquot eqr) (isasetsetquot _).

Definition nil_chain : Chain := (1,,(One,,tt)).
Definition nil : List := setquotpr eqr nil_chain. (*  *)

(** The induction principle for lists defined using foldr *)
Section list_induction.

Variables (P : hSet) .
Variables (P0 : P )
          (Pc : TT -> P -> P ).

Definition algP : F P -> P.
  intro h.
  generalize (pr2 h).
  use (two_rec_dep (fun a => two_rec _ _ a -> P) _ _(pr1 h)).
  - intros _; exact P0.
  - intro h'.
    cbn in h'.
    apply Pc.
    apply (pr1 h').
    apply (pr2 h').
Defined.

Definition chain_to_P (l:Chain) : P.
  generalize (pr2 l).
  destruct (pr1 l).
  - use Empty_set_rect. (* intros ?; cbn in X. exact P0. *)
  - induction ( n) as [|p IHp].
    + intros ?; exact P0.
    + clear n.
    intro l'.
    apply Pc.
    apply (pr1 l').
    apply algP.
    revert l'.
    apply Fmor.
    apply IHp.
Defined.
Lemma test : chain_to_P nil_chain = P0.
  apply idpath.
Qed.

Lemma myadmit (A:UU) : A.
  admit.
  Admitted.

Lemma compat_chainP : iscomprelfun eqr chain_to_P.
apply myadmit.
Qed.

Definition final (l: List) : P .
  use (setquotuniv eqr _ _ _ l).
  exact chain_to_P.
  exact compat_chainP.
Defined.

Lemma fnil : final nil = P0.
  apply idpath.
Qed.

Definition cons_chain (a:nat) (l:Chain) : Chain.
  use tpair.
  exact (S (pr1 l)).
  use tpair.
  exact Two.
  exact (a,,pr2 l).
Defined.

Definition cons_list_chain (a:nat) (l:List) : Chain.

Lemma fcons a l : final (cons a l) = Pc a l (final l).
  (* il faut d'abord détruire l pour avoir la réduction *)
  destruct l.
  apply idpath.
Qed.
End list_induction.
End List2.