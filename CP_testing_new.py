import re
import subprocess
import csv


with open('/Users/ranjith/Desktop/snmmatching/pyzinc/InstanceResults/Results_CP_MaxCard.csv','w',newline = '') as f:
  print ("Started!....")
  thewriter = csv.writer(f)
  thewriter.writerow(['Instance_No','Model','Solved','Feasible','Status','Objective','Run_time','Solvetime','Solution'])
  t = ['/Users/ranjith/Desktop/snmmatching/pyzinc/SNM_Instances/r5_10_10_2/RealInstance',
         '/Users/ranjith/Desktop/snmmatching/pyzinc/SNM_Instances/r8_20_20_3/RealInstance',
         '/Users/ranjith/Desktop/snmmatching/pyzinc/SNM_Instances/r20_60_60_5/RealInstance',
         '/Users/ranjith/Desktop/snmmatching/pyzinc/SNM_Instances/r40_100_100_6/RealInstance',
         '/Users/ranjith/Desktop/snmmatching/pyzinc/SNM_Instances/r100_250_250_7/RealInstance']

  e = ['r5_10_10_2_','r8_20_20_3_','r20_60_60_5_','r40_100_100_6_','r100_250_250_7_']

  for j in range(1,2):
    u = t[j]
    o = e[j]

    for i in range(11, 200):
     a = '/Users/ranjith/Desktop/snmmatching/pyzinc/InstanceResults/CP_MaxCard/' + o + "/" + o + str(i) + 'CP_MaxCard' + '.csv'

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
      obj = 0


      try:

        output1 = subprocess.check_output('mzn2fzn -G gecode CP_MaxCard.mzn "%s" --no-optimise -s' % h, shell=True)
        output = subprocess.check_output('fzn-gecode -time 600000 -a -s 1 CP_MaxCard.fzn |solns2out --output-time CP_MaxCard.ozn', shell=True)
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


        #print ('objvalues',objvalues)
        #print ('solutions:', solutions)
        #print (timeelapsed)


        runtimeRe = re.search("runtime:[\s]*(.*?) (.*?)\n", decoded)
        runtime = runtimeRe.groups()[1]
        runtime = re.sub('[()]', '', runtime)
        runtime = runtime.split()
        runtime = float(runtime[0])
        #print (runtime)
        solvetimeRe = re.search("solvetime:[\s]*(.*?) (.*?)\n", decoded)
        solvetime = solvetimeRe.groups()[1]
        solvetime = re.sub('[()]', '', solvetime)
        solvetime = solvetime.split()
        solvetime = float(solvetime[0])
        #print (solvetime)
        solved = '1'


        if (decoded[0] == "="):

            solved = '1'
            satisfied = '0'
            status = 'Unsatisfiable'
            thewriter.writerow([g, 'CP_MaxCard', solved, satisfied, status, objective, runtime, solvetime, "Unsatisfiable"])
            awriter.writerow([objective, 'Unsatisfiable', solvetime, status])

        else:
            objectiveRe = obj
            satisfied = '1'
            Solution = solutions[len(solutions) - 1]
            if Solution == " ":
                Solution = -1
            #Solution = Solution.replace("Solution = ", "")
            objective = objvalues[len(objvalues) - 1]
            equal = re.search("=",decoded)
            if equal == None:
             status = 'not optimal'
            else:
             status = 'optimal'
            thewriter.writerow([g, 'CP_MaxCard', solved, satisfied, status, objective, runtime,solvetime, Solution])


            for k in range(0, len(objvalues)):
                awriter.writerow([objvalues[k], solutions[k], timeelapsed[k], status])

      except subprocess.TimeoutExpired:
          print("Instance",i, " has timed out")
          solved = '0'
          satisfied = '0'
          status = "Not Optimal"
          if (objective == 0 or objective == None):
            objective = -1
            thewriter.writerow([g, 'CP_MaxCard', solved, satisfied, status, objective, runtime,solvetime, Solution])
            awriter.writerow([objective, 0, solvetime, status])
          else:

            thewriter.writerow([g, 'CP_MaxCard', solved, satisfied, status, objective, runtime,solvetime, Solution])
            for k in range(0, len(objvalues)):
               awriter.writerow([objvalues[k], solutions[k], timeelapsed[k], status])

      print("CP_MaxCard_Model has successfully run Instance", i,j)

  print("Cheers!")