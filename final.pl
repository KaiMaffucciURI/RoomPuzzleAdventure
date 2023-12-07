% text adventure puzzle game

:- dynamic alive/1.

% keeps track of what is in the player inventory
:- dynamic inv/1.
% keeps track of what is in the room
:- dynamic room/1.

% predicates to write to screen
print_inv :- writeln('Items in your inventory: '), forall(inv(X), writeln(X)).
print_room :- writeln('Items in the room: '), forall(room(X), writeln(X)).
print_all :- print_inv, writeln(''), print_room.

% retracts everything from everywhere
nuke :- retractall(inv(_)), retractall(room(_)). 

% message if player tried to apply something in inv to something in room that doesnt work
invalid_sel :- writeln('That does not work!').


% logic rundown if player selected door as room item
try_door(Sel) :- (
  Sel = 'hand' ->
    writeln('wake open doors!') ;
  writeln('no waking doors.')
  ).


% main game loop
% add option so when they type [clear] it clears the screen
interact :-
  print_all,
  writeln('Choose something in the room to interact with.'),
  read(RoomSel),
  write('You chose '), write(RoomSel), writeln(''),
  (room(RoomSel) ->
    (
      (RoomSel = 'quit' ; RoomSel = 'exit') ->
        writeln('BYEBYE!'), abort ;
      RoomSel = 'clear' ->
        tty_clear ;
      (
        writeln('Choose something in your inventory to apply: '),
        read(InvSel),
        write('You chose '), write(InvSel), writeln(''),
        % this is where the magic really happens TODO: check if inv selection was valid with inv(InvSel)
        (
          RoomSel = 'door' -> try_door(InvSel) ;
          invalid_sel
        )
      )
    ) ;
    writeln('That item is not in the room, please try again.')
  ),
  interact.


% sets up the starting scenario
start_room :-
  assert(room(door)),
  assert(room(bookshelf)),
  assert(room(chest)),
  assert(room(painting)),
  assert(room(nightstand)),
  assert(room(lamp)).

start_inv :-
  assert(inv(hand)),
  assert(inv(foot)),
  assert(inv(head)).

startup :-
  nuke, 
  start_room,
  start_inv,
  writeln('Welcome! You are trapped in a room.\nPick an item in the room to interact with,\nthen one in your inventory to apply to that item.'), writeln(''),
  interact.