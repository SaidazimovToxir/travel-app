import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:lesson72/models/product.dart';
import 'package:lesson72/services/product_service.dart';

class Homepage extends StatelessWidget {
  const Homepage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Home Page"),
        centerTitle: true,
        backgroundColor: Colors.teal,
      ),
      body: StreamBuilder(
        stream: ProductService().getLocations(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }
          if (!snapshot.hasData) {
            return const Center(
              child: Text("Apida malumot yoq"),
            );
          }
          if (snapshot.hasError) {
            return const Center(
              child: Text("Error bor"),
            );
          }
          final data = snapshot.data!.docs;
          return GridView.builder(
            itemCount: data.length,
            padding: const EdgeInsets.all(15),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 15,
              mainAxisSpacing: 15,
              mainAxisExtent: 300,
            ),
            itemBuilder: (context, index) {
              final travel = Product.fromJson(data[index]);
              return GestureDetector(
                onLongPress: () {},
                onDoubleTap: () {},
                child: Card(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        clipBehavior: Clip.hardEdge,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        height: 150,
                        width: 180,
                        child: Image.network(
                          travel.photoUrl,
                          fit: BoxFit.cover,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(10),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              travel.title,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            Text(travel.location),
                          ],
                        ),
                      ),
                      Row(
                        children: [
                          IconButton(
                            onPressed: () {
                              _showEditLocationDialog(context, travel);
                            },
                            icon: const Icon(
                              Icons.edit,
                              color: Colors.teal,
                            ),
                          ),
                          IconButton(
                            onPressed: () {
                              showDialog(
                                context: context,
                                builder: (context) {
                                  return AlertDialog(
                                    content: const Text(
                                        "Rostan o'chirmoqchimisiz ?"),
                                    actions: [
                                      TextButton(
                                        onPressed: () {
                                          Navigator.pop(context);
                                        },
                                        child: const Text("Cancel"),
                                      ),
                                      TextButton(
                                        onPressed: () {
                                          ProductService()
                                              .deleteLocation(travel.id);
                                          Navigator.pop(context);
                                        },
                                        child: const Text(
                                          "Delete",
                                          style: TextStyle(color: Colors.red),
                                        ),
                                      ),
                                    ],
                                  );
                                },
                              );
                            },
                            icon: const Icon(
                              Icons.delete,
                              color: Colors.red,
                            ),
                          ),
                        ],
                      )
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _showAddLocationDialog(context);
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  void _showAddLocationDialog(BuildContext context) {
    final _titleController = TextEditingController();
    XFile? _pickedImage;
    bool _isLoading = false;

    Future<void> pickImage(ImageSource source) async {
      final picker = ImagePicker();
      final pickedImage =
          await picker.pickImage(source: source, imageQuality: 60);
      if (pickedImage != null) {
        _pickedImage = pickedImage;
      }
    }

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Add Location'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: _titleController,
                    decoration: const InputDecoration(
                      labelText: 'Title',
                    ),
                  ),
                  Row(
                    children: [
                      TextButton(
                        style: TextButton.styleFrom(
                          backgroundColor: Colors.teal,
                        ),
                        onPressed: () => pickImage(ImageSource.camera),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.camera,
                              color: Colors.white,
                            ),
                            Text(
                              'Camera',
                              style: TextStyle(color: Colors.white),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 10),
                      TextButton(
                        style: TextButton.styleFrom(
                          backgroundColor: Colors.teal,
                        ),
                        onPressed: () => pickImage(ImageSource.gallery),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.image,
                              color: Colors.white,
                            ),
                            Text(
                              'Gallery',
                              style: TextStyle(
                                color: Colors.white,
                              ),
                            )
                          ],
                        ),
                      ),
                    ],
                  ),
                  if (_isLoading) const CircularProgressIndicator(),
                ],
              ),
              actionsAlignment: MainAxisAlignment.spaceBetween,
              actions: [
                TextButton(
                  style: TextButton.styleFrom(
                      backgroundColor: Colors.teal.shade300),
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text(
                    'Cancel',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
                FilledButton(
                  style: FilledButton.styleFrom(
                      backgroundColor: Colors.teal.shade300),
                  onPressed: () async {
                    if (_titleController.text.isNotEmpty &&
                        _pickedImage != null) {
                      setState(() {
                        _isLoading = true;
                      });

                      await ProductService().addLocations(
                        _titleController.text,
                        _pickedImage!.path,
                      );
                      Navigator.of(context).pop();
                    }
                  },
                  child: const Text('Add'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showEditLocationDialog(BuildContext context, Product product) {
    final _titleController = TextEditingController(text: product.title);
    XFile? _pickedImage;
    bool _isLoading = false;

    Future<void> pickImage(ImageSource source) async {
      final picker = ImagePicker();
      final pickedImage =
          await picker.pickImage(source: source, imageQuality: 60);
      if (pickedImage != null) {
        _pickedImage = pickedImage;
      }
    }

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Edit Location'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: _titleController,
                    decoration: const InputDecoration(
                      labelText: 'Title',
                    ),
                  ),
                  Row(
                    children: [
                      TextButton(
                        onPressed: () => pickImage(ImageSource.camera),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.camera),
                            Text('Camera'),
                          ],
                        ),
                      ),
                      const SizedBox(width: 10),
                      TextButton(
                        onPressed: () => pickImage(ImageSource.gallery),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [Icon(Icons.image), Text('Gallery')],
                        ),
                      ),
                    ],
                  ),
                  if (_isLoading) const CircularProgressIndicator(),
                ],
              ),
              actionsAlignment: MainAxisAlignment.spaceBetween,
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Cancel'),
                ),
                FilledButton(
                  onPressed: () async {
                    if (_titleController.text.isNotEmpty) {
                      setState(() {
                        _isLoading = true;
                      });

                      await ProductService().updateLocation(
                        product.id,
                        _titleController.text,
                        _pickedImage?.path ?? product.photoUrl,
                      );
                      Navigator.of(context).pop();
                    }
                  },
                  child: const Text('Update'),
                ),
              ],
            );
          },
        );
      },
    );
  }
}
