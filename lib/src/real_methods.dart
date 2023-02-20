part of real;

/// => TAMAM
class Real {
  // -----------------------------------------------------------------------------

  const Real();

  // -----------------------------------------------------------------------------

  /// REF

  // --------------------
  /// TESTED : WORKS PERFECT
  static DatabaseReference  getRef(){
    return FirebaseDatabase.instance.ref();
  }
  // --------------------
  /*
  static DatabaseReference  _getRefFromURL({
  @required String url,
}){
    return FirebaseDatabase.instance.refFromURL(url);
  }
   */
  // --------------------
  /// TESTED : WORKS PERFECT
  static String _createPath({
    @required String collName,
    String docName,
    String key, // what is this ? sub node / doc field
  }){

    String _path = collName;

    if (docName != null){

      _path = '$_path/$docName';

      if (key != null){
        _path = '$_path/$key';
      }

    }

    return _path;
  }
  // --------------------
  /// TESTED : WORKS PERFECT
  static DatabaseReference createPathAndGetRef({
    @required String collName,
    String docName,
    String key,
  }){
    final String path = _createPath(
      collName: collName,
      docName: docName,
      key: key,
    );
    return FirebaseDatabase.instance.ref(path);
  }
  // --------------------
  /// TESTED : WORKS PERFECT
  static DatabaseReference getRefByPath({
    @required String path,
  }){
    assert(path != null, 'PATH SHOULD NOT BE NULL');
    return FirebaseDatabase.instance.ref(path);
  }
  // --------------------
  /*
  static FirebaseDatabase _getSecondaryFirebaseAppDB(String appName){
    final FirebaseApp _secondaryApp = Firebase.app(appName);
    final FirebaseDatabase _database = FirebaseDatabase.instanceFor(app: _secondaryApp);
    return _database;
  }
   */
  // --------------------
  /// TESTED : WORKS PERFECT
  static Map<String, dynamic> _createPathValueMapFromIncrementationMap({
    @required Map<String, dynamic> incrementationMap,
    @required bool isIncrementing,
  }){

    Map<String, dynamic> _output = {};

    final List<String> _keys = incrementationMap.keys.toList();

    if (Mapper.checkCanLoopList(_keys) == true){

      for (final String key in _keys){

        int _incrementationValue = incrementationMap[key];
        if (isIncrementing == false){
          _incrementationValue = -_incrementationValue;
        }

        _output = Mapper.insertPairInMap(
            map: _output,
            key: key,
            value: ServerValue.increment(_incrementationValue)
        );

      }

    }

    return _output;
  }
  // -----------------------------------------------------------------------------

  /// CREATE

  // --------------------
  /// TESTED : WORKS PERFECT
  static Future<Map<String, dynamic>> createColl({
    @required String collName,
    @required Map<String, dynamic> map,
  }) async {
    Map<String, dynamic> _output;

    if (map != null && collName != null){

      await tryAndCatch(
        invoker: 'createColl',
        functions: () async {

          /// GET PATH
          final DatabaseReference _ref = createPathAndGetRef(
            collName: collName,
          );

          /// ADD EVENT LISTENER
          final StreamSubscription _sub = _ref.onValue.listen((event){

            // final _docID = event.previousChildKey;

            _output = Mapper.getMapFromIHLMOO(
              ihlmoo: event.snapshot.value,
              // addDocID: false,
              // onNull: () => blog('Real.createColl : failed to create doc '),
            );

            // if (addDocIDToOutput == true){
            //   _output = Mapper.insertPairInMap(
            //     map: _output,
            //     key: 'id',
            //     value: _docID,
            //   );
            // }

          });

          /// CREATE
          await _ref.set(map);

          /// CANCEL EVENT LISTENER
          await _sub.cancel();

        },
      );

    }

    if (_output != null){
      blog('Real.createColl : map added to [REAL/$collName] : map : ${_output.keys.length} keys');
    }

    return _output;
  }
  // --------------------
  /// TESTED : WORKS PERFECT
  static Future<Map<String, dynamic>> createDoc({
    @required String collName,
    @required Map<String, dynamic> map,
    @required bool addDocIDToOutput,
  }) async {

    Map<String, dynamic> _output;
    String _docID;

    if (map != null && collName != null){

      await tryAndCatch(
        invoker: 'createDoc',
        functions: () async {

          /// GET PATH
          final DatabaseReference _ref = createPathAndGetRef(
            collName: collName,
          );

          /// ADD EVENT LISTENER
          final StreamSubscription _sub = _ref.onChildAdded.listen((event){

            _docID = event.previousChildKey;

            _output = Mapper.getMapFromDataSnapshot(
              snapshot: event.snapshot,
              onNull: () => blog('Real.createDoc : failed to create doc '),
            );

            if (addDocIDToOutput == true){
              _output = Mapper.insertPairInMap(
                map: _output,
                key: 'id',
                value: _docID,
              );
            }

          });

          /// CREATE
          await _ref.push().set(map);

          /// CANCEL EVENT LISTENER
          await _sub.cancel();

        },
      );

    }

    // if (_output != null){
    //   blog('Real.createDoc : map added to [REAL/$collName/$_docID] : map : ${_output.keys.length} keys');
    // }

    return _output;
  }
  // --------------------
  /// TESTED : WORKS PERFECT
  static Future<void> createNamedDoc({
    @required String collName,
    @required String docName,
    @required Map<String, dynamic> map,
    bool pushNodeOneStepDeepWithUniqueID = false,
    bool isUpdating = false,
  }) async {

    if (map != null){

      DatabaseReference _ref = createPathAndGetRef(
        collName: collName,
        docName: docName,
      );

      if (pushNodeOneStepDeepWithUniqueID == true){
        _ref = _ref.push();
      }

      await tryAndCatch(
        invoker: 'createNamedDoc',

        functions: () async {

          await _ref.set(map);

          // blog('Real.reateNamedDoc : added to [REAL/$collName/$docName] : '
          //     'push is $pushNodeOneStepDeepWithUniqueID : map : ${map.keys.length} keys');

        },

      );

    }

  }
  // --------------------
  /// TESTED : WORKS PERFECT
  static Future<Map<String, dynamic>> createDocInPath({
    @required String pathWithoutDocName,
    @required bool addDocIDToOutput,
    @required Map<String, dynamic> map,
    /// random id is assigned as docName if this parameter is not assigned
    String docName,
  }) async {

    // blog('X - createDocInPath ================================ START');

    Map<String, dynamic> _map = map;

    if (_map != null){
      String _docID;

      await tryAndCatch(
        invoker: 'createDoc',
        functions: () async {

          final String _path = docName == null ? pathWithoutDocName : '$pathWithoutDocName/$docName';

          /// GET PATH
          DatabaseReference _ref = getRefByPath(
            path: _path,
          );

          /// ADD EVENT LISTENER
          final StreamSubscription _sub = _ref.onChildAdded.listen((DatabaseEvent event){

            _docID = event.previousChildKey;

            if (addDocIDToOutput == true && _docID != null){
              _map = Mapper.insertPairInMap(
                map: _map,
                key: 'id',
                value: _docID,
              );
            }

          });

          if (docName == null){
            _ref = _ref.push();
          }

          /// CREATE
          await _ref.set(_map);


          /// CANCEL EVENT LISTENER
          await _sub.cancel();

        },
      );
    }

    // if (_map != null){
    //   blog('Real.createDoc : map added to [REAL/$pathWithoutDocName] : map : ${_map.keys.length} keys');
    // }

    // blog('X - createDocInPath ================================ END');

    return _map;
  }
  // --------------------
  /*
  // static Future<Map<String, dynamic>> createNamedDocInPath({
  //   @required BuildContext context,
  //   @required String path,
  //   @required String docName,
  //   @required bool addDocIDToOutput,
  //   @required Map<String, dynamic> map,
  // }) async {
  //
  //   DatabaseReference _ref = _getRefByPath(path: path)
  //
  //   await tryAndCatch(
  //     context: context,
  //     invoker: 'createNamedDoc',
  //
  //     functions: () async {
  //
  //       await _ref.set(map);
  //
  //       blog('Real.createNamedDoc : added to [$path$docName] : push is $pushNodeOneStepDeepWithUniqueID : map : $map');
  //
  //     },
  //
  //   );
  //
  //
  // }
   */
  // -----------------------------------------------------------------------------

  /// READ

  // --------------------
  /// TESTED : WORKS PERFECT
  static Future<List<Map<String, dynamic>>> readPathMaps({
    @required RealQueryModel realQueryModel,
    Map<String, dynamic> startAfter,
    bool addDocIDToEachMap = true,
  }) async {

    List<Map<String, dynamic>> _output = <Map<String, dynamic>>[];

    await tryAndCatch(
      functions: () async {

        final Query _query = RealQueryModel.createQuery(
          queryModel: realQueryModel,
          lastMap: startAfter,
        );

        // final DataSnapshot _snap = await _query.get();

        final DatabaseEvent _event = await _query.once();


        _output = Mapper.getMapsFromDataSnapshot(
          snapshot: _event.snapshot,
          // addDocID: false,
        );

        // Mapper.blogMaps(_output, invoker: 'readPathMaps');


      },
    );

    return _output;
  }
  // --------------------
  /// TESTED : WORKS PERFECT
  static Future<Map<String, dynamic>> readPathMap({
    @required String path,
  }) async {

    Map<String, dynamic> _output = {};

    await tryAndCatch(
      functions: () async {

        final DatabaseReference _ref = getRefByPath(path: path);

        final DataSnapshot _snap = await _ref.get();

        _output = Mapper.getMapFromDataSnapshot(
          snapshot: _snap,
          addDocID: false,
        );

      },
    );

    return _output;
  }
  // --------------------
  /// TESTED : WORKS PERFECT
  static Future<dynamic> readPath({
    /// looks like : 'collName/docName/...'
    @required String path,
  }) async {

    dynamic _output;

    if (TextCheck.isEmpty(path) == false){

      final DatabaseReference _ref = getRefByPath(path: path);

      await tryAndCatch(
        functions: () async {

          final DatabaseEvent event = await _ref.once(DatabaseEventType.value);

          _output = event.snapshot.value;

        },
      );

    }

    return _output;
  }
  // --------------------
  /// TESTED : WORKS PERFECT
  static Future<Map<String, dynamic>> readDoc({
    @required String collName,
    @required String docName,
    bool addDocID = true,
  }) async {

    Map<String, dynamic> _output;

    final DatabaseReference ref = getRef();

    final String _path = _createPath(
      collName: collName,
      docName: docName,
    );

    await tryAndCatch(
      functions: () async {

        final DataSnapshot snapshot = await ref.child(_path).get();

        _output = Mapper.getMapFromDataSnapshot(
          snapshot: snapshot,
          onNull: () => blog('Real.readDoc : No data available : path : $_path.'),
          addDocID: addDocID,
          // onExists:
        );

      },
    );

    // if (_output != null){
    //   blog('Real.readDoc : found map in (REAL/$collName/$docName) of ${_output.keys.length} keys');
    // }

    return _output;
  }
  // --------------------
  /// TESTED : WORKS PERFECT
  static Future<Map<String, dynamic>> readDocOnce({
    @required String collName,
    @required String docName,
    bool addDocID = true,
  }) async {

    final DatabaseReference ref = createPathAndGetRef(
      collName: collName,
      docName: docName,
    );

    Map<String, dynamic> _map;

    await tryAndCatch(
      functions: () async {

        final DatabaseEvent event = await ref.once(DatabaseEventType.value);

        _map = Mapper.getMapFromDataSnapshot(
          snapshot: event.snapshot,
          addDocID: addDocID,
        );

      },
    );

    // if (_map != null){
      // blog('Real.readDocOnce : map read from [REAL/$collName/$docName] : map : ${_map.length} keys');
    // }

    return _map;
  }
  // -----------------------------------------------------------------------------

  /// UPDATE

  // --------------------
  /// TESTED : WORKS PERFECT
  static Future<void> updateColl({
    @required String collName,
    @required Map<String, dynamic> map,
  }) async {
    if (map != null){

      await createColl(
        collName: collName,
        map: map,
      );

    }
  }
  // --------------------
  /// TESTED : WORKS PERFECT
  static Future<void> updateDoc({
    @required String collName,
    @required String docName,
    @required Map<String, dynamic> map,
  }) async {

    if (map != null){

      await createNamedDoc(
        collName: collName,
        docName: docName,
        map: map,
        isUpdating: true,
      );

    }

  }
  // --------------------
  /// TESTED : WORKS PERFECT
  static Future<void> updatePath({
    @required String path,
    @required Map<String, dynamic> map,
  }) async {

    if (path != null && map != null){

      final String _pathWithoutDocName = TextMod.removeTextAfterLastSpecialCharacter(path, '/');
      final String _docName = TextMod.removeTextBeforeLastSpecialCharacter(path, '/');

      if (
          TextCheck.isEmpty(_pathWithoutDocName) == false
          &&
          TextCheck.isEmpty(_docName) == false
      ){

        await createDocInPath(
          pathWithoutDocName: _pathWithoutDocName,
          docName: _docName,
          addDocIDToOutput: false,
          map: map,
        );

      }

    }


  }
  // --------------------
  /// TESTED : WORKS PERFECT
  static Future<void> updateDocField({
    @required String collName,
    @required String docName,
    @required String fieldName,
    @required dynamic value,
  }) async {

    // blog('updateDocField : START');

    /// NOTE : if value is null the pair will be deleted on real db map

    if (collName != null && docName != null && fieldName != null){

      final DatabaseReference _ref = createPathAndGetRef(
        collName: collName,
        docName: docName,
        key: fieldName,
      );

      /// this is stupid shit
      // if (pushNodeOneStepWithNewUniqueID == true){
      //   _ref = _ref.push();
      // }

      await tryAndCatch(
          functions: () async {

            await _ref.set(value).then((_) {
              // Data saved successfully!
              // blog('Real.updateField : updated (Real/$collName/$docName/$fieldName) : $value');

            })
                .catchError((error) {
              // The write failed...
            });


          }
      );

    }

    // blog('updateDocField : END');

  }
  // --------------------
  /*
  static Future<void> updateMultipleDocsAtOnce({
    @required List<RealNode> nodes,

  }) async {

    // Get a key for a new Post.
    final newPostKey = FirebaseDatabase.instance.ref().child('posts').push().key;

    final Map<String, Map> updates = {};
    updates['/posts/$newPostKey'] = postData;
    updates['/user-posts/$uid/$newPostKey'] = postData;

    return FirebaseDatabase.instance.ref().update(updates);
  }
   */
  // --------------------
  /// TESTED : WORKS PERFECT
  static Future<void> incrementDocFields({
    @required BuildContext context,
    @required String collName,
    @required String docName,
    @required Map<String, dynamic> incrementationMap,
    @required bool isIncrementing,
  }) async {

    if (incrementationMap != null){

      final DatabaseReference _ref = createPathAndGetRef(
        collName: collName,
        docName: docName,
      );

      final Map<String, dynamic> _updatesMap = _createPathValueMapFromIncrementationMap(
        incrementationMap: incrementationMap,
        isIncrementing: isIncrementing,
      );

      await _ref.update(_updatesMap);

    }

  }
  // -----------------------------------------------------------------------------

  /// DELETE

  // --------------------
  /// TESTED : WORKS PERFECT
  static Future<void> deleteDoc({
    @required String collName,
    @required String docName,
  }) async {

    final DatabaseReference _ref = createPathAndGetRef(
      collName: collName,
      docName: docName,
    );

    await tryAndCatch(
      functions: () async {

        await _ref.remove();

      },
    );

  }
  // --------------------
  /// TESTED : WORKS PERFECT
  static Future<void> deleteField({
    @required String collName,
    @required String docName,
    @required String fieldName,
  }) async {

    await updateDocField(
      collName: collName,
      docName: docName,
      fieldName: fieldName,
      value: null,
    );

  }
  // --------------------
  /// TESTED : WORKS PERFECT
  static Future<void> deletePath({
    @required String pathWithDocName,
  }) async {

    if (TextCheck.isEmpty(pathWithDocName) == false){

      final DatabaseReference _ref = getRefByPath(
        path: pathWithDocName,
      );

      await tryAndCatch(
        functions: () async {
          await _ref.remove();
        },
      );

    }

  }
  // -----------------------------------------------------------------------------

  /// TRANSACTION & ATOMICS & LISTENERS

  // --------------------
  /// PLAN : TEST ME AND RE-WRITE THE ENTIRE APP
  static Future<TransactionResult> runTransaction ({
    @required BuildContext context,
    @required String collName,
    @required String docName,
    @required Function(Map<String, dynamic> map) doStuff,
    @required bool applyLocally,
  }) async {

    final DatabaseReference _ref = createPathAndGetRef(
        collName: collName,
        docName: docName
    );

    final TransactionResult _result = await _ref.runTransaction((Object map){

      // Ensure a map at the ref exists.
      if (map == null) {
        return Transaction.abort();
      }

      else {

        final Map<String, dynamic> _map = Map<String, dynamic>.from(map as Map);

        doStuff(_map);

        return Transaction.success(_map);
      }

    },
      applyLocally: applyLocally,
    );

    blog('runTransaction : _result.committed : ${_result.committed} : _result.snapshot : ${_result.snapshot}');

    return _result;
  }
  // --------------------
  /*
  void addStar(uid, key) async {
    Map<String, Object?> updates = {};
    updates["posts/$key/stars/$uid"] = true;
    updates["posts/$key/starCount"] = ServerValue.increment(1);
    updates["user-posts/$key/stars/$uid"] = true;
    updates["user-posts/$key/starCount"] = ServerValue.increment(1);
    return FirebaseDatabase.instance.ref().update(updates);
  }
 */
  // -----------------------------------------------------------------------------

  /// CLONE

  // --------------------
  /// TESTED : WORKS PERFECT
  static Future<void> cloneColl({
    @required String oldCollName, // collName/docName/node/mapName
    @required String newCollName, // newCollName
  }) async {

    final Object _object = await readPath(path: oldCollName);

    if (_object != null){

      // ( remove collName )=> docName/node/mapName
      String _newPath = TextMod.removeTextBeforeFirstSpecialCharacter(oldCollName, '/');
      // ( remove mapName )=> docName/node
      _newPath = TextMod.removeTextAfterLastSpecialCharacter(_newPath, '/');
      // ( add newCollName )=> newCollName/docName/node
      _newPath = '$newCollName/$_newPath';

      // mapName
      // final String _mapName = TextMod.removeTextBeforeLastSpecialCharacter(oldCollName, '/');

      final DatabaseReference _ref = getRefByPath(
        path: newCollName,
      );

      await tryAndCatch(functions: () async {
        await _ref.set(_object);
      });

    }

  }
  // --------------------
  /// TESTED : WORKS PERFECT
  static Future<void> clonePath({
    @required String oldPath,
    @required String newPath,
  }) async {

    blog('1 - clonePath : START');

    final Object _object = await readPath(path: oldPath);

    blog('2 - clonePath : GOT OBJECT : ( ${_object != null} )');

    if (_object != null){

      final DatabaseReference _ref = getRefByPath(
        path: newPath,
      );

      blog('3 - clonePath : GOT REF : ( $_ref )');

      await tryAndCatch(
          invoker: 'clonePath',
          functions: () async {

            await _ref.set(_object);

            blog('4 - clonePath : OBJECT IS SET IN NEW PATH');

      });

    }

    blog('5 - clonePath : END');
  }
  // -----------------------------------------------------------------------------

  /// BLOG

  // --------------------
  /// TESTED : WORKS PERFECT
  static void blogDatabaseEvent({
    @required DatabaseEvent event,
    String invoker = 'blogDatabaseEvent',
  }){
    blog('blogDatabaseEvent : $invoker ----------------------- START');

    if (event != null){
      blog('event.snapshot : ${event.snapshot}');
      blog('event.snapshot.value : ${event.snapshot.value}');
      blog('event.snapshot.key : ${event.snapshot.key}');
      blog('event.snapshot.children : ${event.snapshot.children}');
      blog('event.snapshot.ref : ${event.snapshot.ref}');
      blog('event.snapshot.exists : ${event.snapshot.exists}');
      blog('event.snapshot.priority : ${event.snapshot.priority}');
      blog('event.snapshot.child("id") : ${event.snapshot.child('id')}');
      blog('event.snapshot.hasChild("id") : ${event.snapshot.hasChild('id')}');
      blog('event.type : ${event.type}');
      blog('event.type.name : ${event.type.name}');
      blog('event.type.index : ${event.type.index}');
      blog('event.previousChildKey : ${event.previousChildKey}');
    }
    else {
      blog('event is null');
    }


    blog('blogDatabaseEvent : $invoker ----------------------- END');
  }
  // --------------------
  /// TESTED : WORKS PERFECT
  static void blogDataSnapshot ({
    @required DataSnapshot snapshot,
    String invoker = 'blogDataSnapshot',
  }){
    blog('blogDataSnapshot : $invoker ----------------------- START');
    if (snapshot != null){
      blog('snapshot.key : ${snapshot.key}');
      blog('snapshot.value : ${snapshot.value}');
      blog('snapshot.value.runtimeType : ${snapshot.value.runtimeType}');
      blog('snapshot.children : ${snapshot.children}');
      blog('snapshot.priority : ${snapshot.priority}');
      blog('snapshot.exists : ${snapshot.exists}');
      blog('snapshot.ref : ${snapshot.ref}');
      blog('snapshot.hasChild("id") : ${snapshot.hasChild('id')}');
      blog('snapshot.child("id") : ${snapshot.child('id')}');
    }
    else {
      blog('snapshot is null');
    }
    blog('blogDataSnapshot : $invoker ----------------------- END');
  }
  // -----------------------------------------------------------------------------
}
