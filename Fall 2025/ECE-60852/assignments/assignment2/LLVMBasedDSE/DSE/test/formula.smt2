; 
(set-info :status unknown)
(declare-fun R5 () Int)
(assert
 (let (($x12 (= R5 1024)))
 (= $x12 false)))
(check-sat)
