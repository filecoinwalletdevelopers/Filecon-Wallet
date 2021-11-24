

part of 'select_bloc.dart';



class SelectState extends Equatable {
  final List<ChainWallet> importList;
  final List<List<String>> idList;
  final String label;
  const SelectState({this.importList, this.idList, this.label});

  @override
  // TODO: implement props
  List<Object> get props => [importList, idList, label];

  factory SelectState.idle() {
    var box = OpenedBox.get<ChainWallet>();
    List<ChainWallet> importList = box.values.where((wal) => wal.type != WalletType.id).toList();
    List<List<String>> ids = [];
    Map<String, String> map = {};
    box.values.forEach((wal) {
      if (wal.type == WalletType.id) {
        map[wal.groupHash] = wal.label;
      }
    });
    map.forEach((key, value) {
      ids.add([key, value]);
    });
    return SelectState(importList: importList, idList: ids, label: '');
  }

  SelectState copy({List<ChainWallet> importList,  List<List<String>> idList, String label}){
    return SelectState(
        importList: importList ?? this.importList,
        idList: idList ??  this.idList,
        label: label ?? this.label
    );
  }

  Map<String, List<ChainWallet>> get idWalletMap {
    var box = OpenedBox.get<ChainWallet>();
    Map<String, List<ChainWallet>> res = {};
    box.values.where((wal) => wal.type == WalletType.id).forEach((wal) {
      if (res.containsKey(wal.groupHash)) {
        res[wal.groupHash].add(wal);
      } else {
        res[wal.groupHash] = [wal];
      }
    });
    return res;
  }

}

