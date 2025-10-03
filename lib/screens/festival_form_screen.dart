import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:showboxd/models/festival_model.dart';
import 'package:showboxd/services/festival_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:showboxd/widgets/show_card.dart';

class FestivalFormScreen extends StatefulWidget {
  final FestivalModel? festival;

  const FestivalFormScreen({super.key, this.festival});

  @override
  State<FestivalFormScreen> createState() => _FestivalFormScreenState();
}

class _FestivalFormScreenState extends State<FestivalFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nomeController = TextEditingController();
  final _localController = TextEditingController();
  DateTime? _selectedDate;

  final List<TextEditingController> _artistaControllers = [];
  final FestivalService festivalService = FestivalService();

  bool _showArtistaError = false;

  @override
  void initState() {
    super.initState();
    if (widget.festival != null) {
      final f = widget.festival!;
      _nomeController.text = f.nome;
      _localController.text = f.local;
      _selectedDate = f.data;
      for (var artista in f.artistas) {
        _artistaControllers.add(TextEditingController(text: artista));
      }
    }
  }

  @override
  void dispose() {
    _nomeController.dispose();
    _localController.dispose();
    for (var c in _artistaControllers) {
      c.dispose();
    }
    super.dispose();
  }

  void _addArtistaField() {
    setState(() {
      _artistaControllers.add(TextEditingController());
    });
  }

  void _removeArtistaField(int index) {
    setState(() {
      _artistaControllers.removeAt(index);
    });
  }

  Future<void> _salvarFestival() async {
    final isValid = _formKey.currentState!.validate();
    final artistas = _artistaControllers
        .map((c) => c.text.trim())
        .where((a) => a.isNotEmpty)
        .toList();

    setState(() {
      _showArtistaError = artistas.isEmpty;
    });

    if (!isValid || _selectedDate == null || _showArtistaError) {
      if (_selectedDate == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Selecione uma data para o festival."),
            backgroundColor: Colors.red,
          ),
        );
      }
      return;
    }

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final festivalId =
        widget.festival?.id ??
        FirebaseFirestore.instance.collection('festivais').doc().id;

    final festival = FestivalModel(
      id: festivalId,
      nome: _nomeController.text.trim(),
      local: _localController.text.trim(),
      data: _selectedDate!,
      artistas: artistas,
      criadoPor: user.uid,
    );

    if (widget.festival != null) {
      await festivalService.updateFestival(festival);
    } else {
      await festivalService.addFestival(festival);
    }

    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.festival != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? "Editar Festival" : "Novo Festival"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 3,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      TextFormField(
                        controller: _nomeController,
                        decoration: const InputDecoration(
                          labelText: "Nome do Festival",
                          prefixIcon: Icon(Icons.title),
                          errorStyle: TextStyle(
                            color: Colors.red,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        validator: (v) => v == null || v.isEmpty
                            ? "⚠ Campo obrigatório"
                            : null,
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _localController,
                        decoration: const InputDecoration(
                          labelText: "Local",
                          prefixIcon: Icon(Icons.location_on),
                          errorStyle: TextStyle(
                            color: Colors.red,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        validator: (v) => v == null || v.isEmpty
                            ? "⚠ Campo obrigatório"
                            : null,
                      ),
                      const SizedBox(height: 16),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              ElevatedButton.icon(
                                onPressed: () async {
                                  final date = await showDatePicker(
                                    context: context,
                                    initialDate:
                                        _selectedDate ?? DateTime.now(),
                                    firstDate: DateTime(2000),
                                    lastDate: DateTime(2100),
                                  );
                                  if (date != null) {
                                    setState(() => _selectedDate = date);
                                  }
                                },
                                icon: const Icon(Icons.calendar_today),
                                label: const Text("Escolher Data"),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  _selectedDate == null
                                      ? "Data não selecionada"
                                      : "Data: ${formatDate(_selectedDate!.toLocal())}",
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 16),

              Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 3,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Artistas",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 12),
                      ..._artistaControllers.asMap().entries.map((entry) {
                        final index = entry.key;
                        final controller = entry.value;
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4),
                          child: Row(
                            children: [
                              Expanded(
                                child: TextFormField(
                                  controller: controller,
                                  decoration: InputDecoration(
                                    labelText: "Artista ${index + 1}",
                                    prefixIcon: const Icon(Icons.music_note),
                                  ),
                                ),
                              ),
                              IconButton(
                                icon: const Icon(
                                  Icons.remove_circle,
                                  color: Colors.red,
                                ),
                                onPressed: () => _removeArtistaField(index),
                              ),
                            ],
                          ),
                        );
                      }),
                      if (_showArtistaError)
                        const Padding(
                          padding: EdgeInsets.only(top: 8),
                          child: Text(
                            "⚠ Adicione pelo menos um artista",
                            style: TextStyle(
                              color: Colors.red,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      TextButton.icon(
                        onPressed: _addArtistaField,
                        icon: const Icon(Icons.add),
                        label: const Text("Adicionar artista"),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 24),

              ElevatedButton.icon(
                onPressed: _salvarFestival,
                icon: const Icon(Icons.save),
                label: Text(
                  isEditing ? "Atualizar Festival" : "Salvar Festival",
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
                  foregroundColor: Colors.black,
                  minimumSize: const Size.fromHeight(50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
