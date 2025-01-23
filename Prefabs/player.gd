class_name Player extends XROrigin3D

@onready var lh: OpenXRFbHandTrackingMesh = %LeftHandMesh; ## Left hand skeleton
@onready var rh: OpenXRFbHandTrackingMesh = %RightHandMesh; ## Right hand skeleton
@onready var left_hand_xr_node: XRNode3D = %LeftHandXRNode
@onready var right_hand_xr_node: XRNode3D = %RightHandXRNode

func get_left_fingertip_transform(hand: OpenXRFbHandTrackingMesh = lh) -> Array[Vector3]:
	var lh_tips: Array[Vector3] = [
		hand.to_global( hand.get_bone_global_pose( hand.find_bone("LeftThumbTip") ).origin),
		hand.to_global( hand.get_bone_global_pose( hand.find_bone("LeftIndexTip") ).origin),
		hand.to_global( hand.get_bone_global_pose( hand.find_bone("LeftMiddleTip") ).origin),
		hand.to_global( hand.get_bone_global_pose( hand.find_bone("LeftRingTip") ).origin),
		hand.to_global( hand.get_bone_global_pose( hand.find_bone("LeftLittleTip") ).origin),
	];
	return lh_tips;
	
func get_right_fingertip_transform(hand: OpenXRFbHandTrackingMesh = self.rh) -> Array[Vector3]:
	var rh_tips: Array[Vector3] = [
		hand.to_global( hand.get_bone_global_pose( hand.find_bone("RightThumbTip") ).origin),
		hand.to_global( hand.get_bone_global_pose( hand.find_bone("RightIndexTip") ).origin),
		hand.to_global( hand.get_bone_global_pose( hand.find_bone("RightMiddleTip") ).origin),
		hand.to_global( hand.get_bone_global_pose( hand.find_bone("RightRingTip") ).origin),
		hand.to_global( hand.get_bone_global_pose( hand.find_bone("RightLittleTip") ).origin),
	];
	return rh_tips;
