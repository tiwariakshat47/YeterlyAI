import tensorflow as tf
from tensorflow.keras.preprocessing.image import ImageDataGenerator
from tensorflow.keras.applications import MobileNetV2
from tensorflow.keras.layers import Dense, GlobalAveragePooling2D, Dropout
from tensorflow.keras.models import Model
from tensorflow.keras.callbacks import EarlyStopping, ReduceLROnPlateau

# Constants
img_height, img_width = 224, 224
batch_size = 32
initial_epochs = 10
fine_tune_epochs = 10

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

# Dynamically calculate steps per epoch
train_steps_per_epoch = train_data.samples // batch_size
val_steps_per_epoch = test_data.samples // batch_size

# Load MobileNetV2 with pretrained weights
base_model = MobileNetV2(input_shape=(img_height, img_width, 3), include_top=False, weights='imagenet')
base_model.trainable = False  # Initially freeze all layers

# Add custom classification layers
x = base_model.output
x = GlobalAveragePooling2D()(x)
x = Dense(1024, activation='relu')(x)
x = Dropout(0.3)(x)  # Increased dropout rate
x = Dense(512, activation='relu')(x)  # Additional dense layer
x = Dropout(0.2)(x)
predictions = Dense(train_data.num_classes, activation='softmax')(x)

# Construct the final model
model = Model(inputs=base_model.input, outputs=predictions)

# Compile the model with an initial low learning rate
model.compile(optimizer=tf.keras.optimizers.Adam(learning_rate=1e-4), loss='categorical_crossentropy', metrics=['accuracy'])

# Early stopping and learning rate reduction on plateau
early_stopping = EarlyStopping(monitor='val_loss', patience=5, restore_best_weights=True)
reduce_lr = ReduceLROnPlateau(monitor='val_loss', factor=0.5, patience=3, min_lr=1e-6)

# Train the model with frozen layers
history = model.fit(
    train_data,
    steps_per_epoch=train_steps_per_epoch,
    epochs=initial_epochs,
    validation_data=test_data,
    validation_steps=val_steps_per_epoch,
    callbacks=[early_stopping, reduce_lr]
)

# Gradual unfreezing of the last few layers
unfreeze_layers = 20
for layer in base_model.layers[-unfreeze_layers:]:
    layer.trainable = True

# Recompile the model with a lower learning rate for fine-tuning
model.compile(optimizer=tf.keras.optimizers.Adam(learning_rate=1e-4), loss='categorical_crossentropy', metrics=['accuracy'])

# Fine-tuning with unfrozen layers
fine_tune_history = model.fit(
    train_data,
    steps_per_epoch=train_steps_per_epoch,
    epochs=fine_tune_epochs,
    validation_data=test_data,
    validation_steps=val_steps_per_epoch,
    callbacks=[early_stopping, reduce_lr]
)

# Evaluate the model on the test set
test_loss, test_acc = model.evaluate(test_data)
print(f"Test Accuracy: {test_acc * 100:.2f}%")

# Save the final model
model.save("asl_classifier_finetuned.h5")
