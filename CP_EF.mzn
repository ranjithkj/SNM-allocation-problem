include "globals.mzn";
% Problem Size

int: total_requests;
int: total_goods;
int: Seekers;
int: Donors;

% Declaration of Seekers:

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
set of int: goods = {i | i in 1..total_goods};
set of int: requests = {i | i in 1..total_requests};
array[1..Donors] of int: num_goods_per_donor;
array [1..total_goods+1] of float: P;

% Decision Variables:
array[1..total_requests] of var 0..total_goods: r;
array[1..Seekers,1..total_goods+1] of var 0..total_goods: u;

% Objective Function:
var int: obj; 

% Constraint 1
constraint 
    forall( i in 1..total_requests)
    (
        r[i] in 'union'(set_preferred_goods[i],{0})
    );
    
% Constraint 2 which enforces all requests to take different values                                                                                    
constraint alldifferent_except_0(r);    

% Constraint 3 -> Connecting weight values to seeker values:

constraint forall(s in 1..Seekers)

( 

forall(i in 1..total_requests)

( 
   element(r[i]+1, [u[s,g] | g in 1..total_goods+1], h[r[i]+1,s+1]) 
)

);

% Constraint 4 -> Helping us with the objective function
constraint global_cardinality(r,[0],[obj]);

% constraint 5 -> envy-freeness using cp:

constraint forall(s,t in 1..Seekers where s!= t)

(

sum(i in set_request_seekers[s]) (P[u[s,r[i]+1]+1]) >= sum(j in set_request_seekers[t]) (P[u[s, r[j]+1]+1])

);


% Objective function   
solve minimize obj;

output ["Solution = "] ++ ["(" ++ show_int(1,i) ++ "," ++ show_int(1,j) ++ ")" ++ if i == total_requests then "\n" else "," endif |i in 1..total_requests, j in 1..total_goods where fix(r[i]) == j] ++ ["\n"] ++ ["obj = " ++ "\(obj)" ++ "\n"];


%output ["\(s)"];

%output ["\(w)"];