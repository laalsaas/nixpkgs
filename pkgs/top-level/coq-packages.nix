{ lib, callPackage, newScope, recurseIntoAttrs, ocamlPackages_4_05 }:

let
  mkCoqPackages' = self: coq:
    let callPackage = newScope self ; in rec {
      inherit callPackage coq;
      coqPackages = self;

      contribs = recurseIntoAttrs
        (callPackage ../development/coq-modules/contribs {});

      autosubst = callPackage ../development/coq-modules/autosubst {};
      bignums = if lib.versionAtLeast coq.coq-version "8.6"
        then callPackage ../development/coq-modules/bignums {}
        else null;
      category-theory = callPackage ../development/coq-modules/category-theory { };
      CoLoR = callPackage ../development/coq-modules/CoLoR {};
      coq-ext-lib = callPackage ../development/coq-modules/coq-ext-lib {};
      coq-haskell = callPackage ../development/coq-modules/coq-haskell { };
      coqprime = callPackage ../development/coq-modules/coqprime {};
      coquelicot = callPackage ../development/coq-modules/coquelicot {};
      dpdgraph = callPackage ../development/coq-modules/dpdgraph {};
      equations = callPackage ../development/coq-modules/equations { };
      fiat_HEAD = callPackage ../development/coq-modules/fiat/HEAD.nix {};
      flocq = callPackage ../development/coq-modules/flocq {};
      heq = callPackage ../development/coq-modules/heq {};
      HoTT = callPackage ../development/coq-modules/HoTT {};
      interval = callPackage ../development/coq-modules/interval {};
      iris = callPackage ../development/coq-modules/iris {};
      math-classes = callPackage ../development/coq-modules/math-classes { };
      mathcomp = callPackage ../development/coq-modules/mathcomp { };
      metalib = callPackage ../development/coq-modules/metalib { };
      multinomials = callPackage ../development/coq-modules/multinomials {};
      paco = callPackage ../development/coq-modules/paco {};
      QuickChick = callPackage ../development/coq-modules/QuickChick {};
      ssreflect = callPackage ../development/coq-modules/ssreflect { };
      stdpp = callPackage ../development/coq-modules/stdpp { };
      tlc = callPackage ../development/coq-modules/tlc {};
      Velisarios = callPackage ../development/coq-modules/Velisarios {};
    };

  filterCoqPackages = coq:
    lib.filterAttrsRecursive
    (_: p:
      let pred = p.compatibleCoqVersions or (_: true);
      in pred coq.coq-version
    );

in rec {

  /* The function `mkCoqPackages` takes as input a derivation for Coq and produces
   * a set of libraries built with that specific Coq. More libraries are known to
   * this function than what is compatible with that version of Coq. Therefore,
   * libraries that are not known to be compatible are removed (filtered out) from
   * the resulting set. For meta-programming purposes (inpecting the derivations
   * rather than building the libraries) this filtering can be disabled by setting
   * a `dontFilter` attribute into the Coq derivation.
   */
  mkCoqPackages = coq:
    let self = mkCoqPackages' self coq; in
    if coq.dontFilter or false then self
    else filterCoqPackages coq self;

  coq_8_5 = callPackage ../applications/science/logic/coq {
    ocamlPackages = ocamlPackages_4_05;
    version = "8.5pl3";
  };
  coq_8_6 = callPackage ../applications/science/logic/coq {
    ocamlPackages = ocamlPackages_4_05;
    version = "8.6.1";
  };
  coq_8_7 = callPackage ../applications/science/logic/coq {
    version = "8.7.2";
  };
  coq_8_8 = callPackage ../applications/science/logic/coq {
    version = "8.8.2";
  };
  coq_8_9 = callPackage ../applications/science/logic/coq {
    version = "8.9+beta1";
  };

  coqPackages_8_5 = mkCoqPackages coq_8_5;
  coqPackages_8_6 = mkCoqPackages coq_8_6;
  coqPackages_8_7 = mkCoqPackages coq_8_7;
  coqPackages_8_8 = mkCoqPackages coq_8_8;
  coqPackages_8_9 = mkCoqPackages coq_8_9;
  coqPackages = coqPackages_8_8;
  coq = coqPackages.coq;

}
