Require Export List.
Set Implicit Arguments.

Ltac invcs H := inversion H;clear H;repeat subst.

Ltac invcsSome := repeat match goal with H : Some _ = Some _ |- _ => invcs H end.

Ltac decExists := repeat match goal with H : exists _, _ |- _ => destruct H end.

Ltac InInvcs := 
  repeat(
    simpl in *;
    intuition;
    try match goal with
    | H : In _ (_ ++ _) |- _ => apply in_app_iff in H;destruct H
    | |- In _ (_ :: _) => constructor
    | |- In _ (_ ++ _) => apply in_app_iff
    end).

Ltac get_goal := match goal with |- ?x => x end.

Ltac get_match H F := 
  match H with
  | context [match ?n with _ => _ end] => F n
  end.

Ltac match_type_context_destruct T C :=
  let F := (fun x => let x' := type of x in match x' with T => destruct x eqn:? end) in
    get_match C F.

Definition box P NT (N : NT) : Type := P.

Inductive sandbox_closer : Prop := ms : sandbox_closer -> sandbox_closer.

Theorem sandbox_closer_exit : sandbox_closer -> False.
  induction 1;trivial.
Qed.

Arguments box : simpl never.

Ltac make_sandbox T N := 
  let f := fresh in
    evar (f : box T N);
    let g := get_goal in 
      let H := fresh in
        assert(sandbox_closer -> g) as H;[intro|clear H].

Ltac exit_sandbox := 
  exfalso;
  match goal with
  | X : sandbox_closer |- _ => apply sandbox_closer_exit in X;tauto
  end.

Ltac set_result N T := match goal with | _ := ?X : box _ N |- _ => unify X T end.

Ltac get_result N := match goal with | _ := ?X : box _ N |- _ => X end.

Ltac clear_result N := match goal with | H := _ : box _ N |- _ => clear H end.