import tensorflow as tf
from tensorflow.keras.preprocessing.image import ImageDataGenerator
from tensorflow.keras.applications import MobileNetV2
from tensorflow.keras.layers import Dense, GlobalAveragePooling2D, Dropout
from tensorflow.keras.models import Model
from tensorflow.keras.callbacks import EarlyStopping, ReduceLROnPlateau, ModelCheckpoint
import matplotlib.pyplot as plt

# Constants
img_height, img_width = 224, 224
batch_size = 32
initial_epochs = 15
fine_tune_epochs = 15  # Increased epochs for fine-tuning
unfreeze_layers = 30   # Increase unfreeze layers for fine-tuning

# Data augmentation for training data
train_datagen = ImageDataGenerator(
    rescale=1.0/255.0,
    rotation_range=30,
    width_shift_range=0.3,
    height_shift_range=0.3,
    shear_range=0.3,
    zoom_range=0.3,
    horizontal_flip=True,
    fill_mode="nearest"
)

test_datagen = ImageDataGenerator(rescale=1.0/255.0)

train_data = train_datagen.flow_from_directory(
    'dataset/train',
    target_size=(img_height, img_width),
    batch_size=batch_size,
    class_mode='categorical'
)

test_data = test_datagen.flow_from_directory(
    'dataset/test',
    target_size=(img_height, img_width),
    batch_size=batch_size,
    class_mode='categorical'
)

# Ensure the data is correctly formatted
print("Classes in training data:", train_data.class_indices)
print("Number of training samples:", train_data.samples)
print("Number of validation samples:", test_data.samples)

# Load MobileNetV2 with pretrained weights
base_model = MobileNetV2(input_shape=(img_height, img_width, 3), include_top=False, weights='imagenet')
base_model.trainable = False  # Initially freeze all layers

# Add custom classification layers
x = base_model.output
x = GlobalAveragePooling2D()(x)
x = Dense(1024, activation='relu')(x)
x = Dropout(0.5)(x)  # Added dropout to reduce overfitting
x = Dense(512, activation='relu')(x)
predictions = Dense(train_data.num_classes, activation='softmax')(x)

# Construct the final model
model = Model(inputs=base_model.input, outputs=predictions)

# Compile the model with an initial low learning rate
model.compile(optimizer=tf.keras.optimizers.Adam(learning_rate=1e-4), loss='categorical_crossentropy', metrics=['accuracy'])

# Callbacks for training
model_checkpoint = ModelCheckpoint('best_model.keras', save_best_only=True, monitor='val_accuracy', mode='max')
early_stopping = EarlyStopping(monitor='val_loss', patience=5, restore_best_weights=True)
reduce_lr = ReduceLROnPlateau(monitor='val_loss', factor=0.5, patience=3, min_lr=1e-6)

# Train the model with frozen layers
history = model.fit(
    train_data,
    steps_per_epoch=train_data.samples // batch_size,
    epochs=initial_epochs,
    validation_data=test_data,
    validation_steps=test_data.samples // batch_size,
    callbacks=[early_stopping, reduce_lr, model_checkpoint]
)

# Gradually unfreezing more layers for fine-tuning
base_model.trainable = True
for layer in base_model.layers[:-unfreeze_layers]:
    layer.trainable = False

# Recompile the model with a lower learning rate for fine-tuning
model.compile(optimizer=tf.keras.optimizers.Adam(learning_rate=1e-5), loss='categorical_crossentropy', metrics=['accuracy'])

# Fine-tuning with unfrozen layers
fine_tune_history = model.fit(
    train_data,
    steps_per_epoch=train_data.samples // batch_size,
    epochs=fine_tune_epochs,
    validation_data=test_data,
    validation_steps=test_data.samples // batch_size,
    callbacks=[early_stopping, reduce_lr, model_checkpoint]
)

# Evaluate the model on the test set
test_loss, test_acc = model.evaluate(test_data)
print(f"Test Accuracy: {test_acc * 100:.2f}%")

# Save the final fine-tuned model
model.save("asl_classifier_finetuned.keras")

# Plotting training history
def plot_training(history, fine_tune_history):
    acc = history.history['accuracy'] + fine_tune_history.history['accuracy']
    val_acc = history.history['val_accuracy'] + fine_tune_history.history['val_accuracy']
    loss = history.history['loss'] + fine_tune_history.history['loss']
    val_loss = history.history['val_loss'] + fine_tune_history.history['val_loss']

    epochs_range = range(len(acc))

    plt.figure(figsize=(12, 8))

    # Accuracy plot
    plt.subplot(1, 2, 1)
    plt.plot(epochs_range, acc, label='Training Accuracy')
    plt.plot(epochs_range, val_acc, label='Validation Accuracy')
    plt.legend(loc='lower right')
    plt.title('Training and Validation Accuracy')

    # Loss plot
    plt.subplot(1, 2, 2)
    plt.plot(epochs_range, loss, label='Training Loss')
    plt.plot(epochs_range, val_loss, label='Validation Loss')
    plt.legend(loc='upper right')
    plt.title('Training and Validation Loss')

    plt.show()

# Plotting the training results
plot_training(history, fine_tune_history)
