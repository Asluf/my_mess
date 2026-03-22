import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/member.dart';
import '../providers/project_provider.dart';

class AddMemberScreen extends StatefulWidget {
  final int projectId;
  final Member? member;

  const AddMemberScreen({
    super.key,
    required this.projectId,
    this.member,
  });

  @override
  State<AddMemberScreen> createState() => _AddMemberScreenState();
}

class _AddMemberScreenState extends State<AddMemberScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late int _selectedColorIndex;
  bool get _isEditing => widget.member != null;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.member?.name ?? '');
    _selectedColorIndex = widget.member?.colorIndex ??
        (context.read<ProjectProvider>().members.length %
            Member.avatarColors.length);
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    final provider = context.read<ProjectProvider>();
    final name = _nameController.text.trim();

    if (_isEditing) {
      await provider.updateMember(
        widget.member!.copyWith(name: name, colorIndex: _selectedColorIndex),
      );
    } else {
      await provider.addMember(widget.projectId, name);
    }

    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          _isEditing ? 'Edit Member' : 'Add Member',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: theme.primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: CircleAvatar(
                  radius: 40,
                  backgroundColor: Member
                      .avatarColors[_selectedColorIndex % Member.avatarColors.length],
                  child: Text(
                    _nameController.text.isNotEmpty
                        ? _nameController.text[0].toUpperCase()
                        : '?',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              TextFormField(
                controller: _nameController,
                autofocus: !_isEditing,
                textCapitalization: TextCapitalization.words,
                decoration: InputDecoration(
                  labelText: 'Name',
                  hintText: 'e.g. Ahmed',
                  prefixIcon: const Icon(Icons.person_outline),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                validator: (v) =>
                    (v == null || v.trim().isEmpty) ? 'Enter a name' : null,
                onChanged: (_) => setState(() {}),
              ),
              const SizedBox(height: 24),
              Text('Avatar Color',
                  style: theme.textTheme.titleSmall
                      ?.copyWith(fontWeight: FontWeight.w600)),
              const SizedBox(height: 12),
              Wrap(
                spacing: 12,
                runSpacing: 12,
                children: List.generate(Member.avatarColors.length, (i) {
                  final selected = i == _selectedColorIndex;
                  return GestureDetector(
                    onTap: () => setState(() => _selectedColorIndex = i),
                    child: Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: Member.avatarColors[i],
                        shape: BoxShape.circle,
                        border: selected
                            ? Border.all(color: Colors.white, width: 3)
                            : null,
                        boxShadow: selected
                            ? [
                                BoxShadow(
                                  color: Member.avatarColors[i].withAlpha(150),
                                  blurRadius: 8,
                                  spreadRadius: 2,
                                ),
                              ]
                            : null,
                      ),
                      child: selected
                          ? const Icon(Icons.check,
                              color: Colors.white, size: 22)
                          : null,
                    ),
                  );
                }),
              ),
              const SizedBox(height: 36),
              FilledButton(
                onPressed: _save,
                style: FilledButton.styleFrom(
                  backgroundColor: theme.primaryColor,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  _isEditing ? 'Update Member' : 'Add Member',
                  style: const TextStyle(
                      fontSize: 16, fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
