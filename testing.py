#!/usr/bin/env python3
# -*- coding: utf-8 -*-


import pymzn
import csv
import csv
with open('eggs.csv', 'w', newline='') as csvfile:
    spamwriter = csv.writer(csvfile, delimiter=' ',
                            quotechar='|', quoting=csv.QUOTE_MINIMAL)
    spamwriter.writerow(['Spam'] * 1 + ['Baked Beans'])
    spamwriter.writerow(['Spam', 'Lovely Spam', 'Wonderful Spam'])

q = pymzn.Gurobi()
r = pymzn.Gecode()
#t = pymzn.
w = "Results.csv"
for i in range(0,1):

  h = "/Users/ranjith/Desktop/snmmatching/pyzinc/SNM_Instances/r5_10_10_2/RealInstance"
  g = "/Users/ranjith/Desktop/snmmatching/Instances/3_seekers_and_3_donors_Output/OutputGecode"
  z = "/Users/ranjith/Desktop/snmmatching/Instances/3_seekers_and_3_donors_Output/OutputMIP"
  a = "/Users/ranjith/Desktop/snmmatching/pyzinc/Magic.ozn"
  h = h + str(i) + ".dzn"
  g = g + str(i) + ".dzn"
  z = z + str(i) + ".dzn"

  try:
     # CP_EF
     s = pymzn.minizinc('CP_EF2.mzn', h, solver= r, keep = True, timeout = 10, statistics = True)
     t = pymzn.minizinc('MIP_EF.mzn', h, solver= q, keep = True, timeout = 10, statistics = True)
     #print("CP_EF: ",10 - s['s'], i)
     #s = pymzn.dict2dzn(s, fout=g)
     print (s)
     print (t)
     #break

  except pymzn.MiniZincUnsatisfiableError:
      print("Instance", i, "is unsatisfiable on CP_EF")
  '''
  try:
     # MIP_EF
     w = pymzn.minizinc('MIP_EF.mzn', h, solver= q, timeout=1)[0]
     #e = pymzn.dzn2dict(w, rebase_arrays=False)
     print("MIP_EF: ", w['s'], i)
     #break

  except pymzn.MiniZincUnsatisfiableError:
       print("Instance", i, "is unsatisfiable on MIP_EF")


  # CP_MaxCard
  try:
           # CP_MaxCard
           s = pymzn.minizinc('CP_MaxCard.mzn', h, solver=r, timeout=1)[0]
           # s = pymzn.dict2dzn(s, fout=g)
           print("CP_MaxCard: ",10 - s['s'], i)
           # break

  except pymzn.MiniZincUnsatisfiableError:
           print("Instance", i, "is unsatisfiable on CP_MaxCard")

  # MIP_MaxCard
  try:
            # MIP_EF
            w = pymzn.minizinc('MIP_MaxCard.mzn', h, solver=q, timeout=1)[0]
            # e = pymzn.dzn2dict(w, rebase_arrays=False)
            print("MIP_EF: ", w['s'], i)
            # break

  except pymzn.MiniZincUnsatisfiableError:
               print("Instance", i, "is unsatisfiable on MIP_MaxCard")
  '''
  #x = pymzn.solns2out(s, a)
  # log time start

  # log time stop
print ("Cheers! ")
