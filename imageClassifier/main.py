import tensorflow as tf
from tensorflow.keras.preprocessing.image import ImageDataGenerator
from tensorflow.keras.applications import MobileNetV2
from tensorflow.keras.layers import Dense, GlobalAveragePooling2D, Dropout, BatchNormalization
from tensorflow.keras.models import Model
from tensorflow.keras.callbacks import EarlyStopping, ReduceLROnPlateau, ModelCheckpoint, LearningRateScheduler
import matplotlib.pyplot as plt
from sklearn.metrics import confusion_matrix, classification_report
import numpy as np

# Constants
img_height, img_width = 224, 224
batch_size = 32
initial_epochs = 20
fine_tune_epochs = 15
unfreeze_layers = 20  # Gradually unfreeze layers for fine-tuning

# Learning rate scheduler
def lr_scheduler(epoch, lr):
    return lr * 0.95 if epoch > 5 else lr

lr_callback = LearningRateScheduler(lr_scheduler)

# Data augmentation and preprocessing with MobileNetV2
train_datagen = ImageDataGenerator(
    preprocessing_function=tf.keras.applications.mobilenet_v2.preprocess_input,
    rotation_range=20,  # Reduced rotation
    width_shift_range=0.2,  # Reduced width shift
    height_shift_range=0.2,  # Reduced height shift
    shear_range=0.2,  # Reduced shear
    zoom_range=0.2,  # Reduced zoom
    horizontal_flip=True,
    fill_mode='nearest',
    validation_split=0.2  # 80% training, 20% validation
)

test_datagen = ImageDataGenerator(
    preprocessing_function=tf.keras.applications.mobilenet_v2.preprocess_input
)

# Load train, validation, and test datasets
train_data = train_datagen.flow_from_directory(
    'dataset/train',
    target_size=(img_height, img_width),
    batch_size=batch_size,
    class_mode='categorical',
    subset='training'
)

validation_data = train_datagen.flow_from_directory(
    'dataset/train',
    target_size=(img_height, img_width),
    batch_size=batch_size,
    class_mode='categorical',
    subset='validation'
)

test_data = test_datagen.flow_from_directory(
    'dataset/test',
    target_size=(img_height, img_width),
    batch_size=batch_size,
    class_mode='categorical',
    shuffle=False
)

print("Classes:", train_data.class_indices)

# Load MobileNetV2 with pretrained weights
base_model = MobileNetV2(input_shape=(img_height, img_width, 3), include_top=False, weights='imagenet')
base_model.trainable = False  # Freeze all layers initially

# Add custom classification layers with adjusted dropout rates and dense units
x = base_model.output
x = GlobalAveragePooling2D()(x)
x = Dense(512, activation='relu')(x)  # Reduced units
x = BatchNormalization()(x)
x = Dropout(0.6)(x)  # Increased Dropout
x = Dense(256, activation='relu')(x)  # Reduced units
x = BatchNormalization()(x)
x = Dropout(0.6)(x)  # Increased Dropout
predictions = Dense(train_data.num_classes, activation='softmax')(x)

# Construct the final model
model = Model(inputs=base_model.input, outputs=predictions)

# Compile the model with an initial low learning rate
model.compile(optimizer=tf.keras.optimizers.Adam(learning_rate=1e-4), loss='categorical_crossentropy', metrics=['accuracy'])

# Callbacks for training
model_checkpoint = ModelCheckpoint('best_model.keras', save_best_only=True, monitor='val_accuracy', mode='max')
early_stopping = EarlyStopping(monitor='val_loss', patience=3, restore_best_weights=True)  # Stricter patience
reduce_lr = ReduceLROnPlateau(monitor='val_loss', factor=0.5, patience=3, min_lr=1e-6)

# Train the model with frozen layers
history = model.fit(
    train_data,
    steps_per_epoch=train_data.samples // batch_size,
    epochs=initial_epochs,
    validation_data=validation_data,
    validation_steps=validation_data.samples // batch_size,
    callbacks=[early_stopping, reduce_lr, model_checkpoint, lr_callback]
)

# Gradually unfreeze layers for fine-tuning
for layer in base_model.layers[-unfreeze_layers // 2:]:  # Unfreeze half of the last 20 layers initially
    layer.trainable = True

# Recompile the model for fine-tuning with a lower learning rate
model.compile(optimizer=tf.keras.optimizers.Adam(learning_rate=1e-5), loss='categorical_crossentropy', metrics=['accuracy'])

# Fine-tuning with unfrozen layers
fine_tune_history = model.fit(
    train_data,
    steps_per_epoch=train_data.samples // batch_size,
    epochs=fine_tune_epochs,
    validation_data=validation_data,
    validation_steps=validation_data.samples // batch_size,
    callbacks=[early_stopping, reduce_lr, model_checkpoint, lr_callback]
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

# Confusion Matrix and Classification Report
Y_pred = model.predict(test_data)
y_pred = np.argmax(Y_pred, axis=1)
print('Confusion Matrix')
print(confusion_matrix(test_data.classes, y_pred))
print('Classification Report')
target_names = list(test_data.class_indices.keys())
print(classification_report(test_data.classes, y_pred, target_names=target_names))
