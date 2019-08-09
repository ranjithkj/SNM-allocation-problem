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
array[1..total_goods+1,1..Seekers+1] of int: h;
array[1..total_requests,1..total_goods+1] of int: w;

% Declaration of Requests:

array[1..total_requests+1] of int: p_size;
array[1..max(p_size)] of int: preferred_goods;
array[1..total_requests] of set of int: set_preferred_goods;

% Goods:
set of int: requests = {i |i in 1..total_requests};
set of int: goods = {i | i in 1..total_goods};
array[1..Donors] of int: num_goods_per_donor;
array [1..total_goods+1] of float: P;

% Decision Variables:
array[1..total_requests,1..total_goods] of var 0..1: x;
%array[1..Seekers] of var bool: T;

% Objective Function:
var int: obj;

%Constraints

% 1. A request can be matched with only one good.
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
 
% Objective function   
% Maximizing cardinality of satisfied requests
constraint obj = sum(i in requests,j in goods) (x[i,j]) ;


/*constraint forall(i in 1..Seekers)

(

sum(m in set_request_seekers[i], k in set_preferred_goods[m]) (P[w[m,k+1]+1] * x[m,k] ) >= 1.41

);*/

solve maximize obj;


%solve maximize sum(i in 1..total_requests,j in 1..total_goods) (x[i,j]);
output ["Solution = "] ++ ["(" ++ show_int(1,i) ++ "," ++ show_int(1,j) ++ ")" ++ if i == total_requests then "\n" else "," endif|i in 1..total_requests, j in 1..total_goods where fix(x[i,j]) == true] ++ ["\n"] ++ ["obj = " ++ "\(obj)" ++ "\n"];
