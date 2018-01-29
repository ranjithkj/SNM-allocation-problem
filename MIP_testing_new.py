import re
import subprocess
import csv


with open('/Users/ranjith/Desktop/snmmatching/pyzinc/InstanceResults/Results_MIP_EF.csv','w',newline = '') as f:
  print ("Started!....")
  thewriter = csv.writer(f)
  thewriter.writerow(['Instance_No','Model','Solved','Feasible','Status','Objective','Run_time','Solution'])
  t = ['/Users/ranjith/Desktop/snmmatching/pyzinc/SNM_Instances/r2_4_4_2/RealInstance',
       '/Users/ranjith/Desktop/snmmatching/pyzinc/SNM_Instances/r5_10_10_2/RealInstance',
         '/Users/ranjith/Desktop/snmmatching/pyzinc/SNM_Instances/r8_20_20_3/RealInstance',
         '/Users/ranjith/Desktop/snmmatching/pyzinc/SNM_Instances/r20_60_60_5/RealInstance',
         '/Users/ranjith/Desktop/snmmatching/pyzinc/SNM_Instances/r40_100_100_6/RealInstance',
         '/Users/ranjith/Desktop/snmmatching/pyzinc/SNM_Instances/r100_250_250_7/RealInstance']

  e = ['r2_4_4_2','r5_10_10_2_','r8_20_20_3_','r20_60_60_5_','r40_100_100_6_','r100_250_250_7_']

  for j in range(5, 6):
    u = t[j]
    o = e[j]

    for i in range(0, 200):
     a = '/Users/ranjith/Desktop/snmmatching/pyzinc/InstanceResults/MIP_EF/' + o + "/" + o + str(i) + 'MIP_EF' + '.csv'

     with open(a,'w',newline = '') as q:
      awriter = csv.writer(q)
      awriter.writerow(['Objective', 'Solutions', 'Time', 'Status'])
      #h = '/Users/ranjith/Desktop/snmmatching/pyzinc/SNM_Instances/100_250_20_3/RealInstance'
      h = u + str(i) + ".dzn"
      g = o + str(i)

      solved = ''
      satisfied = ''
      runtime = -1
      solvetime = -1
      objective = 0


      try:
        #output = subprocess.check_output ('mzn-gurobi MIP_EF.mzn "%s" --timeout 60000 -s' %h, shell= True)
        output = subprocess.check_output ('mzn-gurobi MIP_EF.mzn "%s" --output-time --timeout 600 -a -s' %h, shell= True)
        decoded = output.decode("utf-8")
        #print (decoded)
        objvalues = re.findall("(.*obj = .*)", decoded)
        solutions = re.findall("(.*Solution.*)", decoded)
        timeelapsed = re.findall("(.*time elapsed.*)", decoded)
        mipstatus = re.findall("(.*MIP Status.*)", decoded)



        for k in range(0, len(objvalues)):

            objvalues[k] = objvalues[k].strip('obj =')
            objvalues[k] = int(str(objvalues[k]))
            solutions[k] = solutions[k].strip('Solution =')
            timeelapsed[k] = timeelapsed[k].strip('% time elapsed:')
            mipstatus[k] = mipstatus[k].strip('  % MIP Status:')

        #print ('objvalues',objvalues)
        #print ('solutions:', solutions)
        #print (timeelapsed)
        #print (mipstatus)


        runtimeRe = re.findall("(.*obj,.*)", decoded)
        runtimeRe = runtimeRe[len(runtimeRe) - 1].replace(',', '')
        f = runtimeRe.split()
        runtime = f[8]
        obj = f[6]
        #print ("runtime:", runtime)
        #print ("objective:", obj)
        solved = '1'


        if (decoded[0] == "="):

            solved = '1'
            satisfied = '0'
            status = 'Unsatisfiable'
            thewriter.writerow([g, 'MIP_EF', solved, satisfied, status, objective, runtime, "Unsatisfiable"])
            awriter.writerow([objective, 'Unsatisfiable', runtime, status])

        else:
            objectiveRe = obj
            satisfied = '1'
            Solution = solutions[len(solutions) - 1]
            if obj == 0:
                Solution  -1
            #Solution = Solution.replace("Solution = ", "")
            objective = obj
            status = mipstatus[len(mipstatus) - 1]
            thewriter.writerow([g, 'MIP_EF', solved, satisfied, status, objective, runtime, Solution])


            for k in range(0, len(objvalues)):
                awriter.writerow([objvalues[k], solutions[k], timeelapsed[k], mipstatus[k] ])

      except subprocess.TimeoutExpired:
          print("Instance",i, " has timed out")
          solved = '0'
          satisfied = '0'
          status = "Not Optimal"
          if (objective == 0):
            objective = -1
            thewriter.writerow([g, 'MIP_EF', solved, satisfied, status, objective, runtime, Solution])
            awriter.writerow([objvalues[k], solutions[k], runtime, mipstatus[k]])
          else:
            thewriter.writerow([g, 'MIP_EF', solved, satisfied, status, objective, runtime, Solution])
            for k in range(0, len(objvalues)):
               awriter.writerow([objvalues[k], solutions[k], timeelapsed[k], mipstatus[k]])

      print("MIP_EF_Model has successfully run Instance", i,j)

  print("Cheers!")