class_name UiGameOverRealRecordsList
extends Control

@export var autoplay := true
var _tween: Tween

const INTROS: Array[String] = [
	"As the sun sets you reflect on your day of hard work and dedication.",
	"You've made it to the end of your shift.",
	"This is really on you for thinking a restaurant that servers hamburgers stands any chance in 202X.",
	"Have you considered switching to tacos? kebabs? Maybe boba? Froyo is due to come back at any point, get in early.",
	"Did you know that _that_ popular hamburger restaurant actually assembles most of them upside down? Weird",
	"The buns are really called Heel and Crown, you can look this up."
]

const OUTROS: Array[String] = [
	"You convinced the bank to give you another loan in exchange for all your badges. Unrealistic but convenient.",
	"The bank has started foreclosing on you no way around that but that takes forever anyway so you can reopen for one more day.",
	"As you mop the floor you realize somebody tipped a tenner. In this economy that's enough to reopen for another shift just go with this.",
	"A food youtuber was so impressed with your deranged elaboration methods they gave you enough money to pay the bank.",
	"Due to a cyberattack the last 24 hours of banking statements have been wiped out. Your bank has no idea what happened. You can reopen safely."
]

const COUNT: Array[String] = [
	"You completed [boing]%d[/boing] hamburgers. Good job!",
	"You completed [boing]%d[/boing] hamburgers. That's a lot!",
	"You completed [boing]%d[/boing] sandwiches. We don't count the failed ones.",
	"You closed [boing]%d[/boing] hamburgers. That's a lot!",
	"You closed [boing]%d[/boing] sanwiches. That's a lot!",
]

const EXPENSE_COUNT: Array[String] = [
	"Your most expensive sandwich made [boing]%s[/boing]. Neat.",
	"Somebody bought one of your hamburgers for [boing]%s[/boing]. Wild.",
	"At [boing]%s[/boing] your most expensive hamburger was still reasonably priced when accounting for inlation."
]

const PARTS_COUNT: Array[String] = [
	"You somehow fit [boing]%s[/boing] parts in a single sandwich.",
	"Local news reported on your [boing]%s[/boing] part hamburger.",
	"Your [boing]%s[/boing] part sandwich is being shown in a rigged documentary about the health dangers of fast food.",
	"Some say less is more. Not you. your densest hamburger had [boing]%s[/boing] parts.",
]

const HEIGHT_COUNT := [
	"Your tallest sandwich hit [boing]%s[/boing]! Absurd.",
	"Your tallest sandwich hit [boing]%s[/boing]! Extravagant.",
	"At [boing]%s[/boing] your tallest hamburger was recalled for posing a jaw hazard.",
]


func _input(event: InputEvent) -> void:
	TweenHelper.wire_skip(_tween, event)


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	_tween = TweenHelper.maybe_init(self, _tween, Tween.EASE_OUT)
	var all_items := CurrentRun.score.burger_history.filter(func(stats: Variant) -> bool: return stats is not RsFailedBurgerStats)
	var records: Array[UiGameOverRealRecord] = []

	if all_items.size() == 0:
		printerr("lol")
		return

	var sr := SavedRecordsResource.new()

	sr.max_height = SavedRecordFloatResource.new(45.5)

	print(sr.serialize())

	@warning_ignore("unsafe_call_argument")
	records.append(_make_record(INTROS.pick_random() + "\n\n", false))
	@warning_ignore("unsafe_call_argument")
	records.append(_make_record(COUNT.pick_random() % all_items.size(), false))

	SavedRecords.records.maybe_update_tot(all_items.size())

	var expensivest := CurrentRun.score.get_record_burger(RsBurgerStats.Record.PRICE)
	@warning_ignore("unsafe_call_argument")
	records.append(
		_make_record(
			EXPENSE_COUNT.pick_random() % Helper.format_currency(expensivest.price),
			SavedRecords.records.maybe_update_max_money(expensivest.price)
		)
	)

	var most_parts := CurrentRun.score.get_record_burger(RsBurgerStats.Record.LENGTH)
	@warning_ignore("unsafe_call_argument")
	records.append(
		_make_record(PARTS_COUNT.pick_random() % str(most_parts.length), SavedRecords.records.maybe_update_max_parts(most_parts.length))
	)

	var tallest := CurrentRun.score.get_record_burger(RsBurgerStats.Record.HEIGHT)
	@warning_ignore("unsafe_call_argument")
	records.append(
		_make_record(
			HEIGHT_COUNT.pick_random() % Helper.format_size(tallest.height), SavedRecords.records.maybe_update_max_height(tallest.height)
		)
	)

	@warning_ignore("unsafe_call_argument")
	records.append(_make_record("\n\n" + OUTROS.pick_random(), false))

	for record in records:
		add_child(record)

	if autoplay:
		animate_in()

	SavedRecords.save()
	pass  # Replace with function body.


func animate_in() -> void:
	for record: UiGameOverRealRecord in get_children():
		if record.visible == false:
			continue
		_tween = (record).animate_in(_tween)


func _make_record(label: String, is_new_record: bool) -> UiGameOverRealRecord:
	var clone := $Record.duplicate() as UiGameOverRealRecord
	clone.visible = true
	clone.text = label
	clone.is_new_record = is_new_record
	clone.autoplay = autoplay
	return clone
