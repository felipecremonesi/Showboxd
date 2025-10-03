import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:platform_file/platform_file.dart' as fp;
import 'package:showboxd/widgets/show_card.dart';
import '../services/firestore_service.dart';
import '../models/show_model.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';

class ShowFormScreen extends StatefulWidget {
  final ShowModel? show;

  const ShowFormScreen({super.key, this.show});

  @override
  State<ShowFormScreen> createState() => _ShowFormScreenState();
}

class _ShowFormScreenState extends State<ShowFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _artistaController = TextEditingController();
  final _localController = TextEditingController();
  final _setorController = TextEditingController();
  final _musicaFavController = TextEditingController();
  final _artistaAberturaController = TextEditingController();
  final _valorController = TextEditingController();
  final _parcelasController = TextEditingController(text: "1");
  final _duracaoController = TextEditingController();
  final _setlistController = TextEditingController();
  final List<TextEditingController> _setlistControllers = [];

  List<XFile> _selectedImages = []; // Mobile
  List<String> _existingImages = [];
  List<fp.PlatformFile> _webImages = []; // Web
  List<String> _uploadedImageUrls = [];
  List<String> _uploadedImagePaths = [];

  final ImagePicker _picker = ImagePicker();

  final _firestoreService = FirestoreService();
  DateTime? _data;

  bool _copoPersonalizado = false;
  bool _cantaEDanca = false;
  bool _esforcouPortugues = false;
  double _presencaPalco = 0;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    if (widget.show != null) {
      final s = widget.show!;
      _artistaController.text = s.artista;
      _localController.text = s.local;
      _setorController.text = s.setor;
      _musicaFavController.text = s.musicaFav;
      _artistaAberturaController.text = s.artistaAbertura;
      _valorController.text = s.valor.toString();
      _parcelasController.text = s.parcela.toInt().toString();
      _duracaoController.text = s.duracao;
      _data = s.data;
      _copoPersonalizado = s.copoPersonalizado;
      _cantaEDanca = s.cantaEDanca;
      _esforcouPortugues = s.esforcouPortugues;
      _presencaPalco = s.presencaPalco;
      for (var setlist in s.setlist) {
        _setlistControllers.add(TextEditingController(text: setlist));
      }
      for (var foto in s.imageUrls) {
        _uploadedImageUrls.add((foto));
      }
      for (var fotopath in s.imagePaths) {
        _uploadedImagePaths.add((fotopath));
      }
    }
  }

  @override
  void dispose() {
    _artistaController.dispose();
    _localController.dispose();
    _setorController.dispose();
    _musicaFavController.dispose();
    _artistaAberturaController.dispose();
    _valorController.dispose();
    _parcelasController.dispose();
    _duracaoController.dispose();
    _setlistController.dispose();
    super.dispose();
  }

  Future<void> _pickImages() async {
    final pickedImages = await _picker.pickMultiImage();
    if (pickedImages.isNotEmpty) {
      setState(() {
        _selectedImages.addAll(pickedImages);
      });
    }
  }

  Future<void> _uploadImages(String showId) async {
    _uploadedImageUrls = [];
    _uploadedImagePaths = [];

    if (kIsWeb) {
      for (var img in _webImages) {
        final ref = FirebaseStorage.instance.ref().child(
          'shows/$showId/${img.name}',
        );
        await ref.putData(img.bytes!);
        final url = await ref.getDownloadURL();
        _uploadedImageUrls.add(url);
        _uploadedImagePaths.add(ref.fullPath);
      }
    } else {
      for (var img in _selectedImages) {
        final ref = FirebaseStorage.instance.ref().child(
          'shows/$showId/${img.name}',
        );
        await ref.putData(await img.readAsBytes());
        final url = await ref.getDownloadURL();
        _uploadedImageUrls.add(url);
        _uploadedImagePaths.add(ref.fullPath);
      }
    }

    if (widget.show != null) {
      _uploadedImageUrls = [...(widget.show!.imageUrls), ..._uploadedImageUrls];
      _uploadedImagePaths = [
        ...(widget.show!.imagePaths),
        ..._uploadedImagePaths,
      ];
    }
  }

  Future<void> _saveShow() async {
    if (!_formKey.currentState!.validate() || _data == null) {
      _showError(
        "Preencha os campos obrigatórios (Artista, Local, Valor e Data).",
      );
      return;
    }

    final setlist = _setlistControllers
        .map((c) => c.text.trim())
        .where((a) => a.isNotEmpty)
        .toList();

    final user = FirebaseAuth.instance.currentUser;
    final showId =
        widget.show?.id ??
        FirebaseFirestore.instance.collection('shows').doc().id;

    final valor = double.tryParse(_valorController.text) ?? 0;
    final parcelas = int.tryParse(_parcelasController.text) ?? 1;

    await _uploadImages(showId);

    final show = ShowModel(
      id: showId,
      artista: _artistaController.text,
      data: _data!,
      local: _localController.text,
      setor: _setorController.text,
      setlist: setlist,
      musicaFav: _musicaFavController.text,
      duracao: _duracaoController.text,
      artistaAbertura: _artistaAberturaController.text,
      valor: valor,
      valorParcela: parcelas > 0 ? valor / parcelas : valor,
      parcela: parcelas.toDouble(),
      copoPersonalizado: _copoPersonalizado,
      cantaEDanca: _cantaEDanca,
      presencaPalco: _presencaPalco,
      esforcouPortugues: _esforcouPortugues,
      userId: user?.uid ?? "",
      userName: user?.displayName ?? "",
      imageUrls: _uploadedImageUrls,
      imagePaths: _uploadedImagePaths,
    );

    if (widget.show != null) {
      await _firestoreService.updateShow(show);
    } else {
      await _firestoreService.addShow(show);
    }

    Navigator.pop(context);
  }

  void _addSetlistField() {
    setState(() {
      _setlistControllers.add(TextEditingController());
    });
  }

  void _removeSetlistField(int index) {
    setState(() {
      _setlistControllers.removeAt(index);
    });
  }

  void _showError(String message) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Atenção", style: TextStyle(color: Colors.amber)),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("OK"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.show != null;

    return Scaffold(
      appBar: AppBar(title: Text(isEditing ? "Editar Show" : "Novo Show")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              // Informações principais
              Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 3,
                margin: const EdgeInsets.symmetric(vertical: 12),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      TextFormField(
                        controller: _artistaController,
                        decoration: const InputDecoration(
                          labelText: "Artista",
                          prefixIcon: Icon(Icons.person),
                        ),
                        textCapitalization: TextCapitalization.sentences,
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
                        ),
                        textCapitalization: TextCapitalization.sentences,
                        validator: (v) => v == null || v.isEmpty
                            ? "⚠ Campo obrigatório"
                            : null,
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _setorController,
                        decoration: const InputDecoration(
                          labelText: "Setor",
                          prefixIcon: Icon(Icons.view_column),
                        ),
                        textCapitalization: TextCapitalization.sentences,
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          ElevatedButton.icon(
                            onPressed: () async {
                              final picked = await showDatePicker(
                                context: context,
                                initialDate: _data ?? DateTime.now(),
                                firstDate: DateTime(2000),
                                lastDate: DateTime(2100),
                              );
                              if (picked != null) {
                                setState(() => _data = picked);
                              }
                            },
                            icon: const Icon(Icons.calendar_today),
                            label: const Text("Selecionar Data"),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              _data == null
                                  ? "Data não selecionada"
                                  : "Data: ${formatDate(_data!.toLocal())}",
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 3,
                margin: const EdgeInsets.symmetric(vertical: 12),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Experiência",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _musicaFavController,
                        decoration: const InputDecoration(
                          labelText: "Música Favorita",
                          prefixIcon: Icon(Icons.music_note),
                        ),
                        textCapitalization: TextCapitalization.sentences,
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _artistaAberturaController,
                        decoration: const InputDecoration(
                          labelText: "Artista de Abertura",
                          prefixIcon: Icon(Icons.audiotrack),
                        ),
                        textCapitalization: TextCapitalization.sentences,
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _duracaoController,
                        decoration: const InputDecoration(
                          labelText: "Duração do Show",
                          hintText: "Ex: 1.30",
                          prefixIcon: Icon(Icons.timer),
                        ),
                        keyboardType: TextInputType.number,
                      ),
                      const Divider(height: 24),
                      SwitchListTile(
                        value: _copoPersonalizado,
                        onChanged: (v) =>
                            setState(() => _copoPersonalizado = v),
                        title: const Text("Copo Personalizado"),
                      ),
                      SwitchListTile(
                        value: _cantaEDanca,
                        onChanged: (v) => setState(() => _cantaEDanca = v),
                        title: const Text("Canta e Dança"),
                      ),
                      SwitchListTile(
                        value: _esforcouPortugues,
                        onChanged: (v) =>
                            setState(() => _esforcouPortugues = v),
                        title: const Text("Esforçou Português"),
                      ),
                    ],
                  ),
                ),
              ),

              Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 3,
                margin: const EdgeInsets.symmetric(vertical: 12),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: _valorController,
                          decoration: InputDecoration(
                            labelText: "Valor total (R\$)",
                            hintText: "Ex: 499.99",
                            hintStyle: TextStyle(fontSize: 16),
                            prefixIcon: Icon(Icons.attach_money),
                            labelStyle: TextStyle(
                              fontSize: MediaQuery.of(context).size.width < 426
                                  ? 12
                                  : 16,
                            ),
                          ),
                          keyboardType: TextInputType.number,
                          validator: (v) => v == null || v.isEmpty
                              ? "⚠ Campo obrigatório"
                              : null,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: TextFormField(
                          controller: _parcelasController,
                          decoration: const InputDecoration(
                            labelText: "Parcelas",
                            prefixIcon: Icon(Icons.credit_card),
                          ),
                          keyboardType: TextInputType.number,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Setlist
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Setlist",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 12),
                      ..._setlistControllers.asMap().entries.map((entry) {
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
                                    labelText: "Música ${index + 1}",
                                    prefixIcon: const Icon(Icons.music_note),
                                  ),
                                  textCapitalization:
                                      TextCapitalization.sentences,
                                ),
                              ),
                              IconButton(
                                icon: const Icon(
                                  Icons.remove_circle,
                                  color: Colors.red,
                                ),
                                onPressed: () => _removeSetlistField(index),
                              ),
                            ],
                          ),
                        );
                      }),
                      TextButton.icon(
                        onPressed: _addSetlistField,
                        icon: const Icon(Icons.add),
                        label: const Text("Adicionar música"),
                      ),
                    ],
                  ),
                ),
              ),
              Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 3,
                margin: const EdgeInsets.symmetric(vertical: 12),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "Fotos do Show",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(height: 12),

                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: [
                              ..._existingImages.map(
                                (url) => Stack(
                                  children: [
                                    GestureDetector(
                                      onTap: () {
                                        showDialog(
                                          context: context,
                                          builder: (_) => Dialog(
                                            backgroundColor: Colors.black,
                                            child: InteractiveViewer(
                                              child: Image.network(url),
                                            ),
                                          ),
                                        );
                                      },
                                      child: ClipRRect(
                                        borderRadius: BorderRadius.circular(8),
                                        child: Image.network(
                                          url,
                                          width: 100,
                                          height: 100,
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                                    ),
                                    Positioned(
                                      top: 0,
                                      right: 0,
                                      child: GestureDetector(
                                        onTap: () {
                                          setState(() {
                                            _existingImages.remove(url);
                                          });
                                        },
                                        child: const Icon(
                                          Icons.close,
                                          color: Colors.red,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                              ..._selectedImages.map(
                                (image) => Stack(
                                  children: [
                                    GestureDetector(
                                      onTap: () {
                                        showDialog(
                                          context: context,
                                          builder: (_) => Dialog(
                                            backgroundColor: Colors.black,
                                            child: InteractiveViewer(
                                              child: Image.file(
                                                File(image.path),
                                              ),
                                            ),
                                          ),
                                        );
                                      },
                                      child: ClipRRect(
                                        borderRadius: BorderRadius.circular(8),
                                        child: Image.file(
                                          File(image.path),
                                          width: 100,
                                          height: 100,
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                                    ),
                                    Positioned(
                                      top: 0,
                                      right: 0,
                                      child: GestureDetector(
                                        onTap: () {
                                          setState(() {
                                            _selectedImages.remove(image);
                                          });
                                        },
                                        child: const Icon(
                                          Icons.close,
                                          color: Colors.red,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                              GestureDetector(
                                onTap: _pickImages,
                                child: Container(
                                  width: 100,
                                  height: 100,
                                  decoration: BoxDecoration(
                                    color: Colors.grey[800],
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(color: Colors.amber),
                                  ),
                                  child: const Icon(
                                    Icons.add_a_photo,
                                    color: Colors.amber,
                                    size: 32,
                                  ),
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

              const SizedBox(height: 24),

              ElevatedButton.icon(
                icon: _isSaving
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.black,
                        ),
                      )
                    : const Icon(Icons.save),
                label: Text(
                  _isSaving
                      ? (isEditing ? "Atualizando..." : "Salvando...")
                      : (isEditing ? "Atualizar Show" : "Salvar Show"),
                ),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 28,
                    vertical: 14,
                  ),
                  backgroundColor: Colors.orange,
                  foregroundColor: Colors.black,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: _isSaving
                    ? null
                    : () async {
                        setState(() => _isSaving = true);
                        await _saveShow();
                        if (mounted) setState(() => _isSaving = false);
                      },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
