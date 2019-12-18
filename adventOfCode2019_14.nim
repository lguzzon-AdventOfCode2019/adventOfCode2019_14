
import strutils
import sequtils
import tables

const
  gcInputTest00 = """10 ORE => 10 A
1 ORE => 1 B
7 A, 1 B => 1 C
7 A, 1 C => 1 D
7 A, 1 D => 1 E
7 A, 1 E => 1 FUEL"""

  gcInputTest01 = """9 ORE => 2 A
8 ORE => 3 B
7 ORE => 5 C
3 A, 4 B => 1 AB
5 B, 7 C => 1 BC
4 C, 1 A => 1 CA
2 AB, 3 BC, 4 CA => 1 FUEL"""

  gcInputTest02 = """157 ORE => 5 NZVS
165 ORE => 6 DCFZ
44 XJWVT, 5 KHKGT, 1 QDVJ, 29 NZVS, 9 GPVTF, 48 HKGWZ => 1 FUEL
12 HKGWZ, 1 GPVTF, 8 PSHF => 9 QDVJ
179 ORE => 7 PSHF
177 ORE => 5 HKGWZ
7 DCFZ, 7 PSHF => 2 XJWVT
165 ORE => 2 GPVTF
3 DCFZ, 7 NZVS, 5 HKGWZ, 10 PSHF => 8 KHKGT"""

  gcInputTest03 = """2 VPVL, 7 FWMGM, 2 CXFTF, 11 MNCFX => 1 STKFG
17 NVRVD, 3 JNWZP => 8 VPVL
53 STKFG, 6 MNCFX, 46 VJHF, 81 HVMC, 68 CXFTF, 25 GNMV => 1 FUEL
22 VJHF, 37 MNCFX => 5 FWMGM
139 ORE => 4 NVRVD
144 ORE => 7 JNWZP
5 MNCFX, 7 RFSQX, 2 FWMGM, 2 VPVL, 19 CXFTF => 3 HVMC
5 VJHF, 7 MNCFX, 9 VPVL, 37 CXFTF => 6 GNMV
145 ORE => 6 MNCFX
1 NVRVD => 8 CXFTF
1 VJHF, 6 MNCFX => 4 RFSQX
176 ORE => 6 VJHF"""

  gcInputTest04 = """171 ORE => 8 CNZTR
7 ZLQW, 3 BMBT, 9 XCVML, 26 XMNCP, 1 WPTQ, 2 MZWV, 1 RJRHP => 4 PLWSL
114 ORE => 4 BHXH
14 VRPVC => 6 BMBT
6 BHXH, 18 KTJDG, 12 WPTQ, 7 PLWSL, 31 FHTLT, 37 ZDVW => 1 FUEL
6 WPTQ, 2 BMBT, 8 ZLQW, 18 KTJDG, 1 XMNCP, 6 MZWV, 1 RJRHP => 6 FHTLT
15 XDBXC, 2 LTCX, 1 VRPVC => 6 ZLQW
13 WPTQ, 10 LTCX, 3 RJRHP, 14 XMNCP, 2 MZWV, 1 ZLQW => 1 ZDVW
5 BMBT => 4 WPTQ
189 ORE => 9 KTJDG
1 MZWV, 17 XDBXC, 3 XCVML => 2 XMNCP
12 VRPVC, 27 CNZTR => 2 XDBXC
15 KTJDG, 12 BHXH => 5 XCVML
3 BHXH, 2 VRPVC => 7 MZWV
121 ORE => 7 VRPVC
7 XCVML => 6 RJRHP
5 BHXH, 4 VRPVC => 5 LTCX"""

  gcInputOk = """2 RWPCH => 9 PVTL
1 FHFH => 4 BLPJK
146 ORE => 5 VJNBT
8 KDFNZ, 1 ZJGH, 1 GSCG => 5 LKPQG
11 NWDZ, 2 WBQR, 1 VRQR => 2 BMJR
3 GSCG => 4 KQDVM
5 QVNKN, 6 RPWKC => 3 BCNV
10 QMBM, 4 RBXB, 2 VRQR => 1 JHXBM
15 RPWKC => 6 MGCQ
1 QWKRZ => 4 FHFH
10 RWPCH => 6 MZKG
11 JFKGV, 5 QVNKN, 1 CTVK => 4 VQDT
1 SXKT => 5 RPWKC
1 VQDT, 25 ZVMCB => 2 RBXB
6 LGLNV, 4 XSNKB => 3 WBQR
199 ORE => 2 SXKT
1 XSNKB, 6 CWBNX, 1 HPKB, 5 PVTL, 1 JNKH, 9 SXKT, 3 KQDVM => 3 ZKTX
7 FDSX => 6 WJDF
7 JLRM => 4 CWBNX
167 ORE => 5 PQZXH
13 JHXBM, 2 NWDZ, 4 RFLX, 12 VRQR, 10 FJRFG, 14 PVTL, 2 JLRM => 6 DGFG
12 HPKB, 3 WHVXC => 9 ZJGH
1 JLRM, 2 ZJGH, 2 QVNKN => 9 FJRFG
129 ORE => 7 KZFPJ
2 QMBM => 1 RWPCH
7 VJMWM => 4 JHDW
7 PQZXH, 7 SXKT => 9 BJVQM
1 VJMWM, 4 JHDW, 1 MQXF => 7 FDSX
1 RPWKC => 7 WHVXC
1 ZJGH => 1 ZVMCB
1 RWPCH => 3 MPKR
187 ORE => 8 VJMWM
15 CTVK => 5 GSCG
2 XSNKB, 15 ZVMCB, 3 KDFNZ => 2 RFLX
18 QVNKN => 8 XLFZJ
4 CWBNX => 8 ZSCX
2 ZJGH, 1 JLRM, 1 MGCQ => 9 NPRST
13 BJVQM, 2 BCNV => 2 QWKRZ
2 QWKRZ, 2 BLPJK, 5 XSNKB => 2 VRQR
13 HPKB, 3 VQDT => 9 JLRM
2 SXKT, 1 VJNBT, 5 VLWQB => 6 CTVK
2 MPKR, 2 LMNCH, 24 VRQR => 8 DZFNW
2 VQDT => 1 KDFNZ
1 CTVK, 6 FDSX => 6 QVNKN
3 CTVK, 1 QVNKN => 4 HPKB
3 NPRST, 1 KGSDJ, 1 CTVK => 2 QMBM
4 KZFPJ, 1 PQZXH => 5 VLWQB
2 VQDT => 7 KGSDJ
3 MPKR => 2 JNKH
1 KQDVM => 5 XQBS
3 ZKGMX, 1 XQBS, 11 MZKG, 11 NPRST, 1 DZFNW, 5 VQDT, 2 FHFH => 6 JQNF
2 FJRFG, 17 BMJR, 3 BJVQM, 55 JQNF, 8 DGFG, 13 ZJGH, 29 ZKTX => 1 FUEL
27 KZFPJ, 5 VJNBT => 5 MQXF
11 FDSX, 1 WHVXC, 1 WJDF => 4 ZKGMX
1 ZVMCB => 4 NWDZ
1 XLFZJ => 6 LGLNV
13 ZSCX, 4 XLFZJ => 8 LMNCH
1 RPWKC, 1 FDSX, 2 BJVQM => 8 JFKGV
1 WJDF, 1 LKPQG => 4 XSNKB"""
  # gcInput = gcInputTest00 # --> 31
  # gcInput = gcInputTest01 # --> 165
  # gcInput = gcInputTest02 # --> 13312
  # gcInput = gcInputTest03 # --> 180697
  # gcInput = gcInputTest04 # --> 2210736
  gcInput = gcInputOk

  gcLines = gcInput.split('\n')


# if "12" =~ peg"{\d+}":
#   echo matches[0]

# if "12" =~ peg("{\\d+}"):
#   echo matches[0]

# let lV = "2/6 SXKT, 1/6 VJNBT, 5/6 VLWQB"
# let lKey = "VJNBT"
# if lV =~ peg("{\\d+(('*'/'/')\\d+)*} "):
#   echo matches

# if "12" =~ peg("{\\d+}"):
#   echo matches[0]
type
  Eq = tuple[m: BiggestInt, v: seq[tuple[m: BiggestInt, k: string]]]
var lTable: Table[string, Eq]
for lLine in gcLines:
  let lEq = lLine.split(" => ")
  let lVal = lEq[1].split(' ')
  lTable[lVal[1]] = (lVal[0].parseBiggestInt, lEq[0].split(", ").mapIt((
      it.split(" ")[0].parseBiggestInt, it.split(" ")[1])))
echo lTable

var lKeys = lTable["FUEL"].v.mapIt(it.k).filterIt(it != "ORE").filterIt(not lTable[it].v.anyIt(it.k == "ORE"))
if lKeys.len == 0:
  lKeys = lTable["FUEL"].v.mapIt(it.k).filterIt(it != "ORE")
while lKeys.len > 0:
  for lKey in lKeys:
    let lVal = lTable[lKey]
    echo lKey, " -> ", lVal
    let lV = lTable["FUEL"].v
    echo "--> ", lV
    var lNewT: Table[string, BiggestInt]
    for v in lV:
      if v.k == lKey:
        var newMul = v.m div lVal.m
        if v.m mod lVal.m != 0:
          newMul += 1
        for lTo in lVal.v:
          let lNewM = newMul * lTo.m
          if lNewT.hasKeyOrPut(lTo.k, lNewM):
            lNewT[lTo.k] += lNewM
      else:
        if lNewT.hasKeyOrPut(v.k, v.m):
          lNewT[v.k] += v.m
    let lNewV = toSeq(lNewT.pairs).mapIt((it[1], it[0]))
    echo "<-- ", lNewV
    lTable["FUEL"].v = lNewV
  lKeys = lTable["FUEL"].v.mapIt(it.k).filterIt(it != "ORE").filterIt(not lTable[it].v.anyIt(it.k == "ORE"))
  if lKeys.len == 0:
    lKeys = lTable["FUEL"].v.mapIt(it.k).filterIt(it != "ORE")

echo lTable
echo lTable["FUEL"].v.foldl(a + b.m, 0i64)
