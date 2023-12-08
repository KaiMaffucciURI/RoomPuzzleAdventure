% text adventure puzzle game

% I know the '=' operator in prolog isnt an equality, but it still works how I use it throughout the script

% keeps track of what is in the player inventory
:- dynamic inv/1.

% keeps track of what is in the room
:- dynamic room/1.

% lists of things the user can do that is not in the room, but is a valid option still
option(quit).
option(exit).
option(clear).


% predicates to write to screen
print_inv :-
  writeln('Items in your inventory: '),
  forall(inv(X), writeln(X)).

print_room :-
  writeln('Items in the room: '),
  forall(room(X), writeln(X)).

print_option :-
  writeln('Other options (only work on room prompt): '),
  forall(option(X), writeln(X)).
  
print_all :-
  writeln(''), print_room,
  writeln(''), print_inv,
  writeln(''), print_option,
  writeln('').


% retracts everything from everywhere
nuke :- retractall(inv(_)), retractall(room(_)). 


% adds necessary facts for starting the game
start_room :-
  assert(room(bookshelf)),
  assert(room(carpet)),
  assert(room(chest)),
  assert(room(door)),
  assert(room(lamp)),
  assert(room(nightstand)),
  assert(room(painting)).

start_inv :-
  assert(inv(eyes)),
  assert(inv(foot)),
  assert(inv(hand)),
  assert(inv(head)).


% for fire-related deaths
fire_death_msg :-
  writeln('Smoke and heat fills the room!'),
  writeln('You choke on the smoke and get severe heatstroke! RIP!').

% for when the player hits their head against a hard object
brain_death_msg :-
  writeln('You get severe brain damage and pass out. RIP!').
  

% default message if player tried to apply something in inv to something in room that doesnt work
invalid_sel :-
  writeln('That does not make sense!').


% for when the player sticks a non-head body part into the painting
painting_wound_msg :-
  writeln('Skin seals over the wound.').


% predicate to describe each item in the room
describe(Item) :-
  writeln(''),
  (
    Item = bookshelf ->
      writeln('A beautifully-carved piece of furniture stuffed full of tomes new and old.') ;
    Item = carpet ->
      writeln('A nice Turkish rug.') ;
    Item = chest ->
      writeln('The chest is engraved with a foreign script, andd has a lock on its front.') ;
    Item = door ->
      writeln('This is a door: probably the way out, somehow.') ;
    Item = lamp ->
      writeln('A lamp sitting on top of the nightstand, fueled by an oil of some kind. It is lit, and its flame flickers across the room.') ;
    Item = nightstand ->
      writeln('It has a drawer and a top.') ;
    Item = opened_chest ->
      writeln('An already-opened treasure-chest.') ;
    Item = normal_painting ->
      writeln('The painting is of a spiral galaxy, one you have never heard of before.'),
      writeln('Any magic that may have been previously enchanted in the painting has been dispelled') ;
    Item = painting ->
      writeln('The painting is of a spiral galaxy, one you have never heard of before.'),
      writeln('Something seems very off and/or wrong about this painting.'),
      writeln('The painting warps and becomes blurry the longer you stare at it.')
  ).


% uses predicate depending on what room item player selected
% does the same thing if inventory item is eyes no matter what (gives description)
% no need to check if they actually have the item in inventory because we do that earllier

try_room_inv(RoomSel, InvSel) :-
  (
    InvSel = eyes -> describe(RoomSel) ; (
      RoomSel = door -> try_door(InvSel) ;
      RoomSel = bookshelf -> try_bookshelf(InvSel) ;
      RoomSel = carpet -> try_carpet(InvSel) ;
      RoomSel = chest -> try_chest(InvSel) ;
      RoomSel = painting -> try_painting(InvSel) ;
      RoomSel = nightstand -> try_nightstand(InvSel) ;
      RoomSel = lamp -> try_nightstand(InvSel) )
    ; invalid_sel
  ).


% there is sort of a bug with this one, but it actually sort of makes sense and its funny so im leaving it
% (the player can pull infinite books out of the bookshelf)
try_bookshelf(InvSel) :- (
  InvSel = foot ->
    writeln('You kick the bookshelf, and some books fall off.') ;
  InvSel = hand ->
    writeln('You reach for a book in the bookshelf and take it off.'),
    writeln('It appears to be an ancient tome of some kind.'), 
    assert(inv(book)) ;
  InvSel = head ->
    writeln('You ram your head into the bookshelf, and it hurts a lot.'),
    brain_death_msg,
    abort ;
  InvSel = lamp ->
    writeln('You catch the bookshelf on fire!'),
    fire_death_msg,
    abort
  ).


try_carpet(InvSel) :- (
  InvSel = hand -> (
    inv(key) ->
      writeln('You already got the key from under here.') ;
    writeln('Lifting the carpet up, you find a key!'),
    assert(inv(key)) ) ;
  InvSel = foot ->
    writeln('Tapping your foot, you feel a tiny bulge in the carpet.') ;
  InvSel = head ->
    writeln('You bump your head into the carpet. It smells like mildew.')
  ).


try_chest(InvSel) :- (
  InvSel = foot -> (
    inv(treasure) ->
      writeln('The chest is empty.')
    ; writeln('As you kick the chest, you hear the sound of clinging coins coming from inside the chest.') ) ;
  InvSel = hand ->
    writeln('The chest will not budge!') ;
  InvSel = head ->
    writeln('You bash your head into the hard chest, and it hurts a lot!'),
    brain_death_msg,
    abort ;
  InvSel = key ->
    writeln('The key opens the chest!'),
    writeln('There is treasure inside!'),
    writeln('It is a pile of golden coins.'),
    assert(inv(treasure)),
    retract(room(chest)),
    assert(room(opened_chest))
  ).


try_door(InvSel) :- (
  InvSel = foot -> 
    writeln('You kick the door, and it hurts a lot!'),
    writeln('Your foot is broken!'),
    retract(inv(foot)),
    assert(inv(broken_foot)) ;
  InvSel = hand -> 
    writeln('You try to turn the knob, but it does not budge!') ;
  InvSel = head ->
    writeln('You ram your head into the hard door!'),
    writeln('You get severe brain damage and pass out.'),
    writeln('RIP!'),
    abort ;
  InvSel = key ->
    writeln('You put the key in the lock and it opens!'),
    writeln('You escape! You win!'),
    ( inv(treasure) -> writeln('You escaped with the treasure! You are rich!') ; write('') ),
    ( inv(toy) -> writeln('Pervert.') ; write('') ),
    abort
  ).


try_lamp(InvSel) :- (
  InvSel = foot ->
    writeln('Why would you do that?'),
    writeln('The flaming lamp falls over, catching the room on fire.'),
    fire_death_msg,
    abort ;
  InvSel = hand -> (
    inv(lamp) ->
      writeln('You already have the lamp.')
    ;
      writeln('You pick up the flaming lamp and put it into your inventory.'),
      assert(inv(lamp)),
      retract(room(lamp)
    )
  ) ;
  InvSel = head ->
    writeln('REALLY why would you do that?'),
    writeln('The lamp shatters on your head and catches fire!'),
    writeln('You burn to death.'),
    abort
  ).


try_nightstand(InvSel) :- (
  InvSel = foot ->
    writeln('You kick the nightstand.'),
    (
      (inv(toy) ; inv(toy_dust)) -> writeln('The nightstand shakes.') ;
      writeln('You hear a thudding sound from inside the nightstand.')
    ),
    writeln('Suddenly, the lamp on top of the nightstand falls onto the floor!'),
    fire_death_msg,
    abort ;
  InvSel = hand -> (
    inv(toy) ->
      writeln('The drawer is empty.')
    ;
      writeln('You open the drawer to the nightstand'),
      writeln('Here you find a... uh... secret stash of... some kind.'),
      writeln('This is awkward....'),
      assert(inv(toy)) ) ;
  InvSel = head ->
    writeln('You ram your head into the nightstand!'),
    writeln('The lamp shakes and falls over, spewing flaming oil everywhere!'),
    fire_death_msg,
    abort
  ).


try_painting(InvSel) :- (
  inv(book) ->
    writeln('The book was a magical spellbook!'),
    writeln('You cast a spell, sealing the rift to outer space inside the painting.'),
    retract(room(painting)),
    assert(room(normal_painting)) ;
  InvSel = foot ->
    writeln('Your foot is absorbed into the painting!'), 
    painting_wound_msg,
    retract(inv(foot)) ;
  InvSel = hand ->
    writeln('Your hand is absorbed into the painting!'),
    painting_wound_msg,
    retract(inv(hand)) ;
  InvSel = head ->
    writeln('Your head is absorbed into the painting!'),
    writeln('You cannot live with no head! RIP!'),
    abort
  ;
    writeln('The item is absorbed into the painting!'),
    retract(inv(InvSel)), (
      InvSel = key ->
        assert(inv(key_dust)) ;
      InvSel = treasure ->
        assert(inv(treasure_dust)) ;
      InvSel = toy ->
        assert(inv(toy_dust))
    )
  ).


% main game loop
% add option so when they type 'clear' it clears the screen
interact :-

  print_all,
  writeln('Choose something in the room to interact with.'),
  read(RoomSel),
  writeln(''), write('You chose '), write(RoomSel), writeln(''),
  
  ((room(RoomSel) ; option(RoomSel)) -> (
    (RoomSel = 'quit' ; RoomSel = 'exit') ->
      writeln('BYEBYE!'), abort ;
    RoomSel = 'clear' ->
      tty_clear ; (
        writeln('Choose something in your inventory to apply: '),
        read(InvSel),
        writeln(''), write('You chose '), write(InvSel), writeln(''),
      
        % does a thing based on both of the players inputs
        (inv(InvSel) ->
          try_room_inv(RoomSel, InvSel)
        ; writeln('That item is not in your inventory, back to room select.')))
    ) ; writeln('That item is not in the room, please try again.')
  ),
  
  interact.


% sets up the starting scenario
play :-
  nuke, 
  start_room,
  start_inv,
  writeln('Welcome! You are trapped in a room.'),
  writeln('Pick an item in the room to interact with,'),
  writeln('then one in your inventory to apply to that item.\n'),
  interact.