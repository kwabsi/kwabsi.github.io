extends Skeleton2D
class_name SummonSkeleton

func reset():
	for _boneId in range(get_bone_count()):
		get_bone(_boneId).apply_rest()

func applyMaterial(_material:CanvasItemMaterial):
	pass

