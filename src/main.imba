global css body ff:arial inset:0 d:vcc
global css input button ff:inherit

const init_biscuits = [8, 12]
const max_biscuits = Math.max(...init_biscuits)

const phi = (1 + Math.sqrt(5)) / 2

let winnig_positions = []
let i = 1
let s1 = Math.floor(i * phi)
let s2 = s1 + i
while s1 <= max_biscuits
	winnig_positions.push([s1, s2])
	i++
	s1 = Math.floor(i * phi)
	s2 = s1 + i

def arr_sub arr1, arr2
	[arr1[0] - arr2[0], arr1[1] - arr2[1]]

tag Biscuit
	css s:26px rd:14px bd:1px bc:warm8/30 bgc:amber9/80 m:1px
	<self>

tag Box
	prop biscuits
	prop choice

	css .jar bc:sky7/50 bd:3px bdt:none rdb:14px
		s:120px 100px mx:20px
		d:htc flex-wrap:wrap-reverse
	css .status ta:center fs:lg c:warm8
	css .selected bgc:amber9/30

	<self>
		<div.status> biscuits
		<div.jar> for b in [0 ... biscuits]
			<Biscuit .selected=(b >= (biscuits - choice)) key=b>

tag Boxes
	prop biscuits
	prop choices

	css d:hcc

	<self>
		<Box biscuits=biscuits[0] choice=choices[0]>
		<Box biscuits=biscuits[1] choice=choices[1]>

tag Choice
	prop player
	prop mode
	prop choice
	prop max
	prop idx

	css button mx:5px s:42px fs:2xl ff:arial
		rd:xl bd:none bgc:blue2 cursor:pointer
	css input w:40px h:38px bd:1px rd:xl ta:center
		fs:2xl ff:arial bc:blue2 c:warm8

	def computer-move
		mode == 1 and player == 2

	<self>
		<button @click.if(choice > 0)=emit("decreaseChoice", {i: idx})
			disabled=(computer-move())> "-"
		<input id="choice-{idx}" type='text' bind=choice
			@keyup=emit("changeChoice", {i: idx})
			disabled=(computer-move())>
		<button @click.if(choice < max)=emit("increaseChoice", {i: idx})
			disabled=(computer-move())> "+"

tag Choices
	prop choices
	prop biscuits
	prop player
	prop mode
	
	css d:hcc jc:space-around mt:20px
	
	<self>
		<Choice mode=mode player=player choice=choices[0] max=biscuits[0] idx=0>
		<Choice mode=mode player=player choice=choices[1] max=biscuits[1] idx=1>

tag Actions
	prop biscuits
	prop choices
	prop action
	prop mode

	css d:hcc jc:space-around mt:5px
	css button w:140px m:15px h:42px fs:xl
		rd:xl bd:none cursor:pointer
	css	.take bgc:blue2 w:290px
	css	.reset h:38px bgc:cooler2 c:warm7 fs:lg mx:5px
		@disabled c:warm4

	def invalidChoices
		choices[0] == 0 and choices[1] == 0
			or choices[0] != choices[1] and choices[0] != 0 and choices[1] != 0

	def game-in-progress
		biscuits[0] != init_biscuits[0]
			or biscuits[1] != init_biscuits[1]
			or choices[0] != 0 or choices[1] != 0

	<self[d:vcc]>
		<button.take @click=emit("takeBiscuits") disabled=(invalidChoices())> action
		<div[d:hcc]>
			<button.reset @click=emit("resetGame")> "Reset Game"
			<button.reset @click=emit("toggleMode") disabled=(game-in-progress())>
				if mode == 2 then "1 Player" else "2 Players"

tag app
	prop biscuits = init_biscuits.slice()
	prop choices = [0, 0]
	prop player = 1
	prop mode = 1

	def message player
		if biscuits[0] == 0 and biscuits[1] == 0
			if mode == 2
				"Player {player} won!"
			elif player == 1
				"You won!"
			else
				"Computer won!"
		else
			if mode == 2
				"Player {player} - make your choice"
			elif player == 1
				"Make your choice"
			else
				"Computer made a choice"

	def action_text
		if mode == 2 or player == 1
			"Take Biscuits"
		else
			"Continue"

	def reset
		biscuits = init_biscuits.slice()
		choices = [0, 0]
		player = 1

	def change e
		idx = e.detail["i"]
		input = document.getElementById("choice-{idx}")
		txt = input.value
		val = parseInt(txt)
		val = 0 if isNaN(val)
		val = biscuits[idx] if val > biscuits[idx]
		choices[idx] = val

	def increase e
		choices[e.detail["i"]]++

	def decrease e
		choices[e.detail["i"]]--

	def take
		biscuits[0] -= choices[0]
		biscuits[1] -= choices[1]
		choices = [0, 0]
		if biscuits[0] != 0 or biscuits[1] != 0
			player = if player == 1 then 2 else 1
		if mode == 1 and player == 2
			choices = computer_choices()

	def computer_choices
		if biscuits[0] == 0
			[0, biscuits[1]]
		elif biscuits[1] == 0
			[biscuits[0], 0]
		elif biscuits[0] == biscuits[1]
			[biscuits[0], biscuits[1]]
		else 
			if biscuits[1] >= biscuits[0]
				choices = [0, 1]
			else
				choices = [1, 0]
			for pos in winnig_positions
				[a1, a2] = pos
				p1 = [a1, a2]
				p2 = [a2, a1]
				r1 = arr_sub biscuits, p1
				r2 = arr_sub biscuits, p2
				[v1, v2] = r1
				if v1 >= 0 and v2 >= 0
						and (v1 > 0 or v2 > 0)
						and (v1 == 0 or v2 == 0 or v1 == v2)
					choices = [v1, v2]
					break
				[v1, v2] = r2
				if v1 >= 0 and v2 >= 0
						and (v1 > 0 or v2 > 0)
						and (v1 == 0 or v2 == 0 or v1 == v2)
					choices = [v1, v2]
					break
			choices

	def toggle_mode
		mode = if mode == 1 then 2 else 1

	<self[ta:center]
		@resetGame=reset
		@takeBiscuits=take
		@toggleMode=toggle_mode
		@changeChoice=change(e)
		@increaseChoice=increase(e)
		@decreaseChoice=decrease(e)>

		<div[mb:20px]> 
			<p> "You have biscuits in two jars."
			<p> "Players make turns by taking
			{<br>} any number of biscuits from only one jar or
			{<br>} any equal number of biscuits from both jars."
			<p> "Player who takes the last biscuit wins."
		<div[mb:20px c:amber9 fs:lg]> message(player)
		<Boxes biscuits=biscuits choices=choices>
		<Choices biscuits=biscuits choices=choices mode=mode player=player>
		<Actions biscuits=biscuits choices=choices action=action_text() mode=mode>

imba.mount <app>