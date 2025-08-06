class_name TestAction extends ActionLeaf

func tick(actor:Node, blackboard:Blackboard) -> int:
	print("Test Action!")
	return SUCCESS
