import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:gossip_globe/constants.dart';
import 'package:gossip_globe/models/group_model.dart';
import 'package:gossip_globe/models/message_model.dart';
import 'package:gossip_globe/models/user_model.dart';
import 'package:gossip_globe/utilities/global_methods.dart';
import 'package:uuid/uuid.dart';

class GroupProvider extends ChangeNotifier {
  bool _isSloading = false;
  // bool _editSettings = true;
  // bool _approveNewMembers = false;
  // bool _requestToJoin = false;
  // bool _lockMessages = false;

  GroupModel _groupModel = GroupModel(
    creatorUID: '',
    groupName: '',
    groupDescription: '',
    groupImage: '',
    groupId: '',
    lastMessage: '',
    senderUID: '',
    messageType: MessageEnum.text,
    messageId: '',
    timeSent: DateTime.now(),
    createdAt: DateTime.now(),
    isPrivate: true,
    editSettings: true,
    approveMembers: false,
    lockMessages: false,
    requestToJoing: false,
    membersUIDs: [],
    adminsUIDs: [],
    awaitingApprovalUIDs: [],
  );

  final List<UserModel> _groupMembersList = [];
  final List<UserModel> _groupAdminsList = [];

  // getters
  bool get isSloading => _isSloading;
  // bool get editSettings => _editSettings;
  // bool get approveNewMembers => _approveNewMembers;
  // bool get requestToJoin => _requestToJoin;
  // bool get lockMessages => _lockMessages;
  GroupModel get groupModel => _groupModel;
  List<UserModel> get groupMembersList => _groupMembersList;
  List<UserModel> get groupAdminsList => _groupAdminsList;

  // firebase initialization
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // setters
  void setIsSloading({required bool value}) {
    _isSloading = value;
    notifyListeners();
  }

  Future<void> sendRequestToJoinGroup({
    required String groupId,
    required String uid,
    required String groupName,
    required String groupImage,
  }) async {
    await _firestore.collection(Constants.groups).doc(groupId).update({
      Constants.awaitingApprovalUIDs: FieldValue.arrayUnion([uid])
    });

    // TODO  send notification to group admins
  }

  Future<void> acceptRequestToJoinGroup({
    required String groupId,
    required String friendID,
  }) async {
    await _firestore.collection(Constants.groups).doc(groupId).update({
      Constants.membersUIDs: FieldValue.arrayUnion([friendID]),
      Constants.awaitingApprovalUIDs: FieldValue.arrayRemove([friendID])
    });

    _groupModel.awaitingApprovalUIDs.remove(friendID);
    _groupModel.membersUIDs.add(friendID);
    notifyListeners();
  }

  void setEditSettings({required bool value}) {
    _groupModel.editSettings = value;
    notifyListeners();
    if (_groupModel.groupId.isEmpty) return;
    updateGroupDataInFireStore();
  }

  void setApproveNewMembers({required bool value}) {
    groupModel.approveMembers = value;
    notifyListeners();
    if (_groupModel.groupId.isEmpty) return;
    updateGroupDataInFireStore();
  }

  void setRequestToJoin({required bool value}) {
    _groupModel.requestToJoing = value;
    notifyListeners();
    if (_groupModel.groupId.isEmpty) return;
    updateGroupDataInFireStore();
  }

  void setLockMessages({required bool value}) {
    _groupModel.lockMessages = value;
    notifyListeners();
    if (_groupModel.groupId.isEmpty) return;
    updateGroupDataInFireStore();
  }

  void addMemberToGroup({required UserModel groupMember}) {
    _groupMembersList.add(groupMember);
    _groupModel.membersUIDs.add(groupMember.uid);
    notifyListeners();

    // return if groupID is empty - meaning we are creating a new group
    if (_groupModel.groupId.isEmpty) return;
    updateGroupDataInFireStore();
  }

 Future<void> setGroupModel({required GroupModel groupModel}) async {
    _groupModel = groupModel;
    notifyListeners();
  }

  void addMemberToAdmins({required UserModel groupAdmin}) {
    _groupAdminsList.add(groupAdmin);
    _groupModel.adminsUIDs.add(groupAdmin.uid);
    notifyListeners();

    // return if groupID is empty - meaning we are creating a new group
    if (_groupModel.groupId.isEmpty) return;
    updateGroupDataInFireStore();
  }

  Future<void> removeGroupMember({required UserModel groupMember}) async {
    _groupMembersList.remove(groupMember);
    _groupAdminsList.remove(groupMember);
    _groupModel.membersUIDs.remove(groupMember.uid);
    notifyListeners();
    if (_groupModel.groupId.isEmpty) return;
    updateGroupDataInFireStore();
  }

  void removeGroupAdmin({required UserModel groupAdmin}) {
    _groupAdminsList.remove(groupAdmin);
    _groupModel.adminsUIDs.remove(groupAdmin.uid);
    notifyListeners();
    if (_groupModel.groupId.isEmpty) return;
    updateGroupDataInFireStore();
  }

  void changeGroupType() {
    _groupModel.isPrivate = !_groupModel.isPrivate;
    notifyListeners();
    updateGroupDataInFireStore();
  }

  Future<void> clearGroupMembersList() async {
    _groupMembersList.clear();
    _groupAdminsList.clear();
    _groupModel = GroupModel(
      creatorUID: '',
      groupName: '',
      groupDescription: '',
      groupImage: '',
      groupId: '',
      lastMessage: '',
      senderUID: '',
      messageType: MessageEnum.text,
      messageId: '',
      timeSent: DateTime.now(),
      createdAt: DateTime.now(),
      isPrivate: true,
      editSettings: true,
      approveMembers: false,
      lockMessages: false,
      requestToJoing: false,
      membersUIDs: [],
      adminsUIDs: [],
      awaitingApprovalUIDs: [],
    );
    notifyListeners();
  }

  // Future<void> clearGroupAdminsList() async {
  //   _groupAdminsList.clear();
  //   notifyListeners();
  // }

  List<String> getGroupMembersUIDs() {
    return _groupMembersList.map((e) => e.uid).toList();
  }

  List<String> getGroupAdminsUIDs() {
    return _groupAdminsList.map((e) => e.uid).toList();
  }

  Stream<DocumentSnapshot> groupStream({required String groupID}) {
    return _firestore.collection(Constants.groups).doc(groupID).snapshots();
  }

  streamGroupMembersData({required List<String> membersUIDs}) {
    return Stream.fromFuture(
      Future.wait<DocumentSnapshot>(
        membersUIDs.map<Future<DocumentSnapshot>>((uid) async {
          return await _firestore.collection(Constants.users).doc(uid).get();
        }),
      ),
    );
  }

  Future<void> updateGroupDataInFireStore() async {
    try {
      await _firestore
          .collection(Constants.groups)
          .doc(_groupModel.groupId)
          .update(groupModel.toMap());
    } catch (e) {
      print(e.toString());
    }
  }

  Future<List<UserModel>> getGroupMembersDataFromFirestore({
    required bool isAdmin,
  }) async {
    try {
      List<UserModel> membersData = [];

      // get the list of membersUIDs
      List<String> membersUIDs =
          isAdmin ? _groupModel.adminsUIDs : _groupModel.membersUIDs;

      for (var uid in membersUIDs) {
        var user = await _firestore.collection(Constants.users).doc(uid).get();
        membersData.add(UserModel.fromMap(user.data()!));
      }

      return membersData;
    } catch (e) {
      return [];
    }
  }

  Future<void> updateGroupMembersList() async {
    _groupMembersList.clear();

    _groupMembersList
        .addAll(await getGroupMembersDataFromFirestore(isAdmin: false));

    notifyListeners();
  }

  // update the groupAdminsList
  Future<void> updateGroupAdminsList() async {
    _groupAdminsList.clear();

    _groupAdminsList.addAll(await getGroupMembersDataFromFirestore(isAdmin: true));

    notifyListeners();
  }

  //create group
  Future<void> createGroup({
    required GroupModel newGroupModel,
    required File? fileImage,
    required Function onSuccess,
    required Function(String) onFail,
  }) async {
    setIsSloading(value: true);

    try {
      var groupId = const Uuid().v4();
      newGroupModel.groupId = groupId;

      // check if the file image is null
      if (fileImage != null) {
        // upload image to firebase storage
        final String imageUrl = await storeFileToStorage(
            file: fileImage, reference: '${Constants.groupImages}/$groupId');
        newGroupModel.groupImage = imageUrl;
      }

      // add the group admins
      newGroupModel.adminsUIDs = [
        newGroupModel.creatorUID,
        ...getGroupAdminsUIDs()
      ];

      // add the group members
      newGroupModel.membersUIDs = [
        newGroupModel.creatorUID,
        ...getGroupMembersUIDs()
      ];

      // update the global groupModel
      setGroupModel(groupModel: newGroupModel);

      // // add edit settings
      // groupModel.editSettings = editSettings;

      // // add approve new members
      // groupModel.approveMembers = approveNewMembers;

      // // add request to join
      // groupModel.requestToJoing = requestToJoin;

      // // add lock messages
      // groupModel.lockMessages = lockMessages;

      // add group to firebase
      await _firestore
          .collection(Constants.groups)
          .doc(groupId)
          .set(groupModel.toMap());

      // set loading
      setIsSloading(value: false);
      // set onSuccess
      onSuccess();
    } catch (e) {
      setIsSloading(value: false);
      onFail(e.toString());
    }
  }

  Stream<List<GroupModel>> getPrivateGroupsStream({required String userID}) {
    return _firestore
        .collection(Constants.groups)
        .where(Constants.membersUIDs, arrayContains: userID)
        .where(Constants.isPrivate, isEqualTo: true)
        .snapshots()
        .asyncMap((event) {
      List<GroupModel> groups = [];
      for (var group in event.docs) {
        groups.add(GroupModel.fromMap(group.data()));
      }
      return groups;
    });
  }

  Stream<List<GroupModel>> getPublicGroupsStream({required String userID}) {
    return _firestore
        .collection(Constants.groups)
        .where(Constants.isPrivate, isEqualTo: false)
        .snapshots()
        .asyncMap((event) {
      List<GroupModel> groups = [];
      for (var group in event.docs) {
        groups.add(GroupModel.fromMap(group.data()));
      }
      return groups;
    });
  }

  bool isSenderOrAdmin({required MessageModel message, required String uid}) {
    if (message.senderUID == uid) {
      return true;
    } else if (_groupModel.adminsUIDs.contains(uid)) {
      return true;
    } else {
      return false;
    }
  }

  Future<void> exitGroup({
    required String uid,
  }) async {
    // check if the user is the admin of the group
    bool isAdmin = _groupModel.adminsUIDs.contains(uid);

    await _firestore
        .collection(Constants.groups)
        .doc(_groupModel.groupId)
        .update({
      Constants.membersUIDs: FieldValue.arrayRemove([uid]),
      Constants.adminsUIDs:
          isAdmin ? FieldValue.arrayRemove([uid]) : _groupModel.adminsUIDs,
    });

    // remove the user from group members list
    _groupMembersList.removeWhere((element) => element.uid == uid);
    // remove the user from group members uid
    _groupModel.membersUIDs.remove(uid);
    if (isAdmin) {
      // remove the user from group admins list
      _groupAdminsList.removeWhere((element) => element.uid == uid);
      // remove the user from group admins uid
      _groupModel.adminsUIDs.remove(uid);
    }
    notifyListeners();
  }

}
