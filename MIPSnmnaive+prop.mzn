% Header Files
include "globals.mzn";
% Problem Size

int: total_requests;
int: total_goods;
int: Seekers;
int: Donors;

% Declaration of seekers:

array[1..Seekers+1] of int: r_size;
array[1..Seekers] of float: priority_seekers;
array[1..total_requests] of int: requests_seekers;
array[1..Seekers] of set of int: set_request_seekers;
array[1..Seekers] of set of float: set_utility_requests;
array[1..total_requests] of float: utility_requests;

%array[1..total_requests] of int: P_1;
% Function which takes a request and a good as an input and outputs the preference utility 
function float: find_pref_good_wrt_request(int: r, int: g) = max(0,max([if preferred_goods[k] = g 
then P[k - p_size[r]] else 0.0 endif | k in p_size[r]+1..p_size[r+1]]));

% Function which takes a request as an input and outputs the preference utility of that request w.r.t seeker
function float: find_pref_request_wrt_seeker(int: r) = max(0,max([if requests_seekers[k] = r then P[k - r_size[find_seeker(r)]] else 0.0 endif| k in r_size[find_seeker(r)]+1..r_size[find_seeker(r)+1]]));

% Function which takes a request as an input and outputs the seeker
function int: find_seeker(int: r) = max(0,max([if r in set_request_seekers[i] then i else 0 endif | i in 1..Seekers]));


function float: f_1(int: k, int: i) = max(0,max([find_pref_good_wrt_request(j,k)| j in set_request_seekers[i]]));

function int: f_2(int: k, int: i) = max(0,max([if find_pref_good_wrt_request(j,k) != 0 then j else 0 endif|j in set_request_seekers[i]]));

% Declaration of Requests:

array[1..total_requests+1] of int: p_size;
array[1..max(p_size)] of int: preferred_goods;
array[1..total_requests] of set of int: set_preferred_goods;


% Goods:
set of int: goods = {i | i in 1..total_goods};
array[1..Donors] of int: num_goods_per_donor;
array [1..10] of float: P = [1.0, 0.93, 0.80, 0.71, 0.6, 0.48, 0.39, 0.23, 0.11, 0.09];

% Decision Variables:
array[1..total_requests,1..total_goods] of var bool: x;
array[1..total_requests] of var 0..total_goods: r;
array[1..total_goods] of var 0..total_requests: g;
array[1..Seekers] of var bool: T;


% Objective Function:
var float: s;  


%Constraints

% 1. A request can be matched with only one good. The constraint looks a little clumsy because the indices start with 1 rather than 0 in Minizinc.
constraint 
     forall(i in 1..total_requests) 
    (
      sum(k in p_size[i]+1..p_size[i+1])(x[i,preferred_goods[k]]) <= 1 
    );  

% 2. A good can be matched with only one request 
constraint 
   forall(j in 1..total_goods) 
 (
    sum(i in 1..total_requests)(x[i,j]) <= 1
 );  

% 3. A good which is not present in a preference list of a request must not be matched with that request
constraint 
   forall(i in 1..total_requests) 
   (
      sum(k in 'diff'(goods,set_preferred_goods[i])) (x[i,k]) = 0
   );  
  
% 4. A constraint connecting r with binary variables x        
/*constraint 
   forall(i in 1..total_requests)  
   (
      forall(j in 1..total_goods)
      (
         if x[i,j] = 1 then 
            r[i] = j 

         else
             r[i] = r[i]
         endif
       )
   );      
  
*/
constraint 
   forall(i in 1..total_requests)  
   (
      forall(j in 1..total_goods)
      (
         r[i] - total_goods*x[i,j] >= j - total_goods
       )
   );

constraint 
   forall(i in 1..total_requests)  
   (
      forall(j in 1..total_goods)
      (
         r[i] + (total_goods - 1)*x[i,j] <= j + (total_goods - 1)
       )
   );  
          
% 6. A constraint connecting g with binary variables x           
/*constraint 
   forall(i in 1..total_requests)  
   (
      forall(j in 1..total_goods)
      (
         if x[i,j] = 1 then 
            g[j] = i 

         else
             g[j] = g[j]
         endif
       )
   );
*/         

constraint 
   forall(i in 1..total_requests)  
   (
      forall(j in 1..total_goods)
      (
         g[j] - total_requests*x[i,j] >= i - total_requests
      )
   );

constraint 
   forall(i in 1..total_requests)  
   (
      forall(j in 1..total_goods)
      (
         g[j] + (total_requests - 1)*x[i,j] <= i + (total_requests - 1)
      )
   );  
      
% 7.
/*constraint 
   forall( i in 1..total_requests)
   (
       if sum(j in 1..total_goods) (x[i,j]) = 0 then
          r[i] = 0
       else
          r[i] >= 0
       endif   
   );
*/
constraint 
   forall( i in 1..total_requests)
   (
       r[i] <= sum(j in 1..total_goods) (x[i,j] * j)
   );    
% 8. 
constraint 
   forall( j in 1..total_goods)
   (
       if sum(i in 1..total_requests) (x[i,j]) = 0 then
          g[j] = 0
       else
          g[j] >= 0
       endif   
   );     
constraint 
   forall( j in 1..total_goods)
   (
       g[j] <= sum(i in 1..total_requests) (x[i,j] * i)
   );         
                                  
 
% 11. Envy-freeness for Seekers

/*constraint forall(i,j in 1..Seekers where i!= j /\ priority_seekers[i] = priority_seekers[j])

(

sum(m in set_request_seekers[i], k in set_preferred_goods[m]) (find_pref_good_wrt_request(m,k) * x[m,k] ) >=sum(m in set_request_seekers[j], k in set_preferred_goods[m]) ( f_1(k,i) * x[m,k] )

 
);*/

% 12. Envy-freeness for Requests
/*constraint forall(i,j in 1..total_requests where i != j)

(
   sum(k in set_preferred_goods[i]) ( find_pref_good_wrt_request(i,k) * x[i,k] ) >= sum(k in set_preferred_goods[j]) ( find_pref_good_wrt_request(i,k) * x[j,k] )
   
); 
*/

%Proportional Fairness
constraint forall(i in 1..Seekers)

(
   sum(m in set_request_seekers[i], k in set_preferred_goods[m]) (find_pref_good_wrt_request(m,k) * x[m,k] ) >= sum(m in set_request_seekers[i], k in set_preferred_goods[m]) (find_pref_good_wrt_request(m,k)/card(set_preferred_goods[m]))/Seekers

);

constraint forall(i in 1..Seekers)
(
   forall(k in set_request_seekers[i])
   (
      forall(j in 1..total_goods)
      (
         T[i] >= x[k,j]
      )
   )     
    
);    

% Objective function   


% Maximizing cardinality of satisfied requests

s = sum(i in 1..total_requests,j in 1..total_goods) (find_pref_good_wrt_request(i,j) * x[i,j] ) ;
%s = sum(i in 1..total_requests,j in 1..total_goods) ((priority_seekers[find_seeker(i)] * find_pref_request_wrt_seeker(i) * find_pref_good_wrt_request(i,j))* x[i,j]);
% Maximizing sum of preference_matrix and utility over satisfied requests                           

%constraint forall(i in 1..Seekers) (s[i] <= 100);
%s = sum(i in 1..total_requests,j in 1..total_goods) ((priority_seekers[find_seeker(i)] * find_pref_request_wrt_seeker(i) * find_pref_good_wrt_request(i,j))* x[i,j]);
% Maximizing sum of preference_matrix and utility over satisfied requests                           


solve maximize (s);

%solve maximize sum(i in 1..total_requests,j in 1..total_goods) (x[i,j]);

%output ["\(s)"];
%solve maximize s;


