global css body ff:arial inset:0 d:vcc

const init-biscuits = [8, 12]
const phi = (1 + Math.sqrt(5)) / 2
const winning-positions = generate-winning-positions()

let biscuits = init-biscuits.slice()
let choices = [0, 0]
let mode = 1
let player = 1

def generate-winning-positions
	const max = Math.max(...init-biscuits)
	let positions = []
	let i = 1
	let s1 = 1
	let s2 = 2
	while s1 <= max
		positions.push([s1, s2])
		++i
		s1 = Math.floor(i * phi)
		s2 = s1 + i
	positions

def arr-sub arr1, arr2
	[arr1[0] - arr2[0], arr1[1] - arr2[1]]


tag Biscuit
	css s:26px rd:14px bd:1px bc:warm8/30 bgc:amber9/80 m:1px

	<self>

tag Box
	css .jar bc:sky7/50 bd:3px bdt:none rdb:14px
		s:120px 100px mx:20px
		d:htc flex-wrap:wrap-reverse
	css .status ta:center fs:lg c:warm8
	css	.selected bgc:amber9/30

	<self>
		<div.status> biscuits[id]
		<div.jar> for b in [0 ... biscuits[id]]
			<Biscuit .selected=(b >= (biscuits[id] - choices[id]))>

tag Boxes
	css d:hcc

	<self>
		<Box id=0>
		<Box id=1>

tag Choice
	def computer-move
		mode == 1 and player == 2

	def change-value e
		val = e.target.value
		if e.key == "Enter"
			e.target.blur()
		else
			if val != ""
				n = parseInt(val)
				n = 0 if isNaN(n)
				n = biscuits[id] if n > biscuits[id]
				choices[id] = n

	def empty-if-zero e
		e.target.value = "" if choices[id] == 0

	def zero-if-empty e
		if e.target.value == ""
			e.target.value = 0
			choices[id] = 0

	css d:hcc
	css button d:flex ai:center jc:center mx:5px s:42px fs:2xl
		rd:xl bd:none bgc:blue2 c:warm7 cursor:pointer
		@disabled c:warm4
	css input w:40px h:38px bd:1px rd:xl ta:center
		fs:2xl ff:arial bc:blue2 c:warm8

	<self>
		<button type='button' @click.if(choices[id] > 0)=(--choices[id])
			disabled=(computer-move())> "−"
		<input id="choice-{id}" type="text" bind=choices[id]
			autocomplete="off"
			@keyup=change-value
			@focus=empty-if-zero
			@blur=zero-if-empty
			disabled=(computer-move())>
		<button type='button' @click.if(choices[id] < biscuits[id])=(++choices[id])
			disabled=(computer-move())> "+"

tag Choices
	css d:hcc jc:space-around mt:20px
	
	<self>
		<Choice id=0>
		<Choice id=1>

tag Actions
	get action-text
		if mode == 2 or player == 1 then "Take Biscuits" else "Continue"

	get invalid-choices
		choices[0] == 0 and choices[1] == 0
			or choices[0] != choices[1] and choices[0] != 0 and choices[1] != 0

	get game-in-progress
		biscuits[0] != init-biscuits[0]
			or biscuits[1] != init-biscuits[1]
			or choices[0] != 0 or choices[1] != 0

	def take-biscuits
		biscuits[0] -= choices[0]
		biscuits[1] -= choices[1]
		choices = [0, 0]
		if biscuits[0] != 0 or biscuits[1] != 0
			player = if player == 1 then 2 else 1
		if mode == 1 and player == 2
			choices = computer-choices()
			console.log(choices)

	def reset-game
		biscuits = init-biscuits.slice()
		choices = [0, 0]
		player = 1

	def toggle-mode
		mode = if mode == 1 then 2 else 1

	def computer-choices
		if biscuits[0] == 0
			[0, biscuits[1]]
		elif biscuits[1] == 0
			[biscuits[0], 0]
		elif biscuits[0] == biscuits[1]
			[biscuits[0], biscuits[1]]
		else 
			let best-choice = if biscuits[1] >= biscuits[0] then [0, 1] else [1, 0]
			for pos in winning-positions
				[a1, a2] = pos
				p1 = [a1, a2]
				p2 = [a2, a1]
				r1 = arr-sub biscuits, p1
				r2 = arr-sub biscuits, p2
				[v1, v2] = r1
				if v1 >= 0 and v2 >= 0
						and (v1 > 0 or v2 > 0)
						and (v1 == 0 or v2 == 0 or v1 == v2)
					best-choice = [v1, v2]
					break
				[v1, v2] = r2
				if v1 >= 0 and v2 >= 0
						and (v1 > 0 or v2 > 0)
						and (v1 == 0 or v2 == 0 or v1 == v2)
					best-choice = [v1, v2]
					break
			best-choice

	css d:hcc jc:space-around mt:5px
	css button w:140px m:15px h:42px fs:xl
		rd:xl bd:none cursor:pointer c:warm7
		@disabled c:warm5
	css	.take bgc:blue2 w:290px
	css	.reset h:38px bgc:cooler2 fs:lg mx:5px

	<self[d:vcc]>
		<button.take @click=take-biscuits disabled=invalid-choices> action-text
		<div[d:hcc]>
			<button.reset @click=reset-game> "Reset Game"
			<button.reset @click=toggle-mode disabled=game-in-progress>
				if mode == 2 then "1 Player" else "2 Players"

tag app

	get message
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

	<self[ta:center]>
		<div[mb:20px]> 
			<p> "You have biscuits in two jars."
			<p> "Players make turns by taking
			{<br>} any number of biscuits from only one jar or
			{<br>} any equal number of biscuits from both jars."
			<p> "Player who takes the last biscuit wins."
		<div[mb:20px c:amber9 fs:xl]> message
		<Boxes>
		<Choices>
		<Actions>

imba.mount <app>