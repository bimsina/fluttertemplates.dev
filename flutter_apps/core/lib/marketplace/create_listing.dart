import 'package:flutter/material.dart';

class CreateListing extends StatefulWidget {
  const CreateListing({super.key});

  @override
  State<CreateListing> createState() => _CreateListingState();
}

class _CreateListingState extends State<CreateListing> {
  String _category = 'Furniture';
  String _condition = 'Used - good';

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(title: const Text('New listing')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _label(context, 'Photos'),
          SizedBox(
            height: 90,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: [
                Container(
                  width: 90,
                  margin: const EdgeInsets.only(right: 10),
                  decoration: BoxDecoration(
                    border: Border.all(color: scheme.outline),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(Icons.add_a_photo_outlined,
                      color: scheme.onSurfaceVariant),
                ),
                for (var i = 0; i < 2; i++)
                  Container(
                    width: 90,
                    margin: const EdgeInsets.only(right: 10),
                    decoration: BoxDecoration(
                      color: scheme.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(Icons.image,
                        color: scheme.onSurfaceVariant),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          _label(context, 'Title'),
          const TextField(
            decoration: InputDecoration(
                hintText: 'What are you selling?',
                border: OutlineInputBorder()),
          ),
          const SizedBox(height: 16),
          _label(context, 'Category'),
          DropdownButtonFormField<String>(
            initialValue: _category,
            decoration: const InputDecoration(border: OutlineInputBorder()),
            items: const [
              DropdownMenuItem(value: 'Furniture', child: Text('Furniture')),
              DropdownMenuItem(
                  value: 'Electronics', child: Text('Electronics')),
              DropdownMenuItem(value: 'Bikes', child: Text('Bikes')),
              DropdownMenuItem(value: 'Books', child: Text('Books')),
            ],
            onChanged: (v) => setState(() => _category = v ?? _category),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _label(context, 'Price'),
                    const TextField(
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                          prefixText: '\$ ', border: OutlineInputBorder()),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _label(context, 'Condition'),
                    DropdownButtonFormField<String>(
                      initialValue: _condition,
                      isExpanded: true,
                      decoration:
                          const InputDecoration(border: OutlineInputBorder()),
                      items: const [
                        DropdownMenuItem(value: 'New', child: Text('New')),
                        DropdownMenuItem(
                            value: 'Used - good', child: Text('Used - good')),
                        DropdownMenuItem(
                            value: 'For parts', child: Text('For parts')),
                      ],
                      onChanged: (v) =>
                          setState(() => _condition = v ?? _condition),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _label(context, 'Description'),
          const TextField(
            maxLines: 4,
            decoration: InputDecoration(
                hintText: 'Add details buyers will want to know…',
                border: OutlineInputBorder()),
          ),
          const SizedBox(height: 24),
          SizedBox(
            height: 52,
            child: FilledButton(
                onPressed: () {}, child: const Text('Post listing')),
          ),
        ],
      ),
    );
  }

  Widget _label(BuildContext context, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(text,
          style: Theme.of(context)
              .textTheme
              .labelLarge
              ?.copyWith(fontWeight: FontWeight.w600)),
    );
  }
}
