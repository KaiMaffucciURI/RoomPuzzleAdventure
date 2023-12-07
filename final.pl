% TODO: add predicate which prints message if an attempted user apply doesnt work


:- dynamic alive/1.

% keeps track of what is in the player inventory
:- dynamic inv/1.
% keeps track of what is in the room
:- dynamic room/1.

% sets up the starting scenario
start_inv :-
  assert(inv(hand)),
  assert(inv(foot)),
  assert(inv(head)).

start_room :-
  assert(room(door)),
  assert(room(bookshelf)),
  assert(room(chest)),
  assert(room(painting)),
  assert(room(nightstand)),
  assert(room(lamp)).

% predicates to write to screen
print_inv :- writeln('Items in your inventory: '), forall(inv(X), writeln(X)).
print_room :- writeln('Items in the room: '), forall(room(X), writeln(X)).
print_all :- print_inv, writeln(''), print_room.

% retracts everything from everywhere
nuke :- retractall(inv(_)), retractall(room(_)). 

startup :-
  nuke, 
  start_inv,
  start_room,
  writeln('Welcome! You are trapped in a room.\nPick an item in the room to interact with,\nthen another to apply to that item.'),
  interact.

% main game loop
% add option so when they type [clear] it clears the screen
interact :-
  print_all,
  writeln('Choose something in the room to interact with.'),
  read(Input),
  ((Input = 'quit' ; Input = 'exit') ->
    writeln('BYEBYE!'), abort ;
  (Input = 'balls' ->
    writeln('hehe!'), abort) ;
    writeln('hooray!')
  ),
  interact.