part of real;

class RealCollStreamer extends StatelessWidget {
  /// --------------------------------------------------------------------------
  const RealCollStreamer({
    @required this.collName,
    @required this.builder,
    this.loadingWidget,
    this.noValueWidget,
    this.limit = 10,
    Key key
  }) : super(key: key);
  /// --------------------------------------------------------------------------
  final String collName;
  final Widget loadingWidget;
  final Widget noValueWidget;
  final Widget Function(BuildContext, List<Map<String, dynamic>>) builder;
  final int limit;
  /// --------------------------------------------------------------------------
  @override
  Widget build(BuildContext context) {

    return StreamBuilder<DatabaseEvent>(
        stream: FirebaseDatabase.instance.ref(collName).limitToFirst(limit).onValue,
        builder: (_, snapshot){

          /// LOADING
          if (snapshot.connectionState == ConnectionState.waiting){
            return loadingWidget ?? const SizedBox();
          }

          /// NO DATA
          else if (snapshot.hasData == false){
            return noValueWidget ?? const SizedBox();
          }

          /// RECEIVED DATA
          else {

            final List<DataSnapshot> _snapshots = snapshot.data.snapshot.children.toList();

            final List<Map<String, dynamic>> _maps = Mapper.getMapsFromDataSnapshots(
              snapshots: _snapshots,
            );

            /// NO DATA
            if (Mapper.checkCanLoopList(_maps) == null){
              return noValueWidget ?? const SizedBox();
            }

            /// DATA IS GOOD
            else {
              return builder(context, _maps);
            }

          }

        }
    );

  }
/// --------------------------------------------------------------------------
}
