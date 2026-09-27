import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'services/produit_service.dart';

class AjouterProduitScreen extends StatefulWidget {
  final List<Map<String, dynamic>> initialProducts;

  const AjouterProduitScreen({super.key, required this.initialProducts});

  @override
  State<AjouterProduitScreen> createState() => _AjouterProduitScreenState();
}

class _AjouterProduitScreenState extends State<AjouterProduitScreen> {
  late List<Map<String, dynamic>> _products;
  bool _isSaving = false;
  final String? _uid = FirebaseAuth.instance.currentUser?.uid;

  @override
  void initState() {
    super.initState();
    // On initialise avec les données reçues du scan et on ajoute un ID unique
    _products = widget.initialProducts.map((p) {
      final map = Map<String, dynamic>.from(p);
      map['_id'] = UniqueKey().toString(); // Clé unique pour Flutter
      return map;
    }).toList();
  }

  void _ajouterProduitManuel() {
    setState(() {
      _products.add({'name': '', 'quantity': 1, '_id': UniqueKey().toString()});
    });
  }

  Future<void> _enregistrerTout() async {
    if (_products.isEmpty || _uid == null) return;

    setState(() => _isSaving = true);

    try {
      await ProduitService().enregistrerProduits(_products);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Historique mis à jour !"), backgroundColor: Colors.green),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      print("ERREUR FIRESTORE: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Erreur: $e"), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : Colors.black87;

    return Scaffold(
      appBar: AppBar(
        title: Text("Vérification IA", style: TextStyle(color: textColor)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(color: textColor),
        actions: [
          if (!_isSaving)
            IconButton(
              icon: const Icon(Icons.check_circle, color: Colors.green, size: 30),
              onPressed: _enregistrerTout,
            )
        ],
      ),
      body: _isSaving 
        ? const Center(child: CircularProgressIndicator())
        : Column(
            children: [
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.all(15),
                  itemCount: _products.length,
                  itemBuilder: (context, index) {
                    final product = _products[index];
                    return Container(
                      key: ValueKey(product['_id']), // Clé pour corriger le bug de suppression
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Theme.of(context).cardColor,
                        borderRadius: BorderRadius.circular(15),
                        boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 5)],
                      ),
                      child: Row(
                        children: [
                          // Quantité
                          Container(
                            width: 45,
                            height: 45,
                            decoration: const BoxDecoration(color: Colors.blueAccent, shape: BoxShape.circle),
                            child: Center(
                              child: TextFormField(
                                initialValue: _products[index]['quantity'].toString(),
                                keyboardType: TextInputType.number,
                                textAlign: TextAlign.center,
                                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                                decoration: const InputDecoration(border: InputBorder.none),
                                onChanged: (val) => _products[index]['quantity'] = int.tryParse(val) ?? 1,
                              ),
                            ),
                          ),
                          const SizedBox(width: 15),
                          // Nom
                          Expanded(
                            child: TextFormField(
                              initialValue: _products[index]['name'],
                              style: TextStyle(color: textColor),
                              decoration: const InputDecoration(border: InputBorder.none),
                              onChanged: (val) => _products[index]['name'] = val,
                            ),
                          ),
                          // Suppression (Correction bug index)
                          IconButton(
                            icon: const Icon(Icons.remove_circle_outline, color: Colors.redAccent),
                            onPressed: () {
                              setState(() {
                                _products.removeAt(index);
                              });
                            },
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: ElevatedButton.icon(
                  onPressed: _ajouterProduitManuel,
                  icon: const Icon(Icons.add),
                  label: const Text("Ajouter manuellement"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blueAccent,
                    foregroundColor: Colors.white,
                    minimumSize: const Size(double.infinity, 50),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ),
            ],
          ),
    );
  }
}