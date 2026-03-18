$f1 = 'c:\Users\USER\Documents\GitHub\login2Pro\lib\screens\leadManagement\minimalLeadDetails.dart'
$c1 = Get-Content $f1
($c1[0..8243] + $c1[8247..($c1.Count-1)]) | Set-Content $f1

$f2 = 'c:\Users\USER\Documents\GitHub\login2Pro\lib\screens\leadManagement\leadDetails.dart'
$c2 = Get-Content $f2
($c2[0..7817] + $c2[7821..($c2.Count-1)]) | Set-Content $f2
