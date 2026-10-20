# Propuesta de Arquitectura y Plan de Implementación: HabitFlow Mobile

> **Directriz para el Agente en CLI:**  
> Este documento funciona como una **propuesta base y hoja de ruta flexible**, no como un contrato rígido. Durante la construcción del proyecto tienes libertad para proponer mejoras, ajustar librerías según compatibilidad del SDK de Flutter instalado, simplificar flujos o adaptar la arquitectura según las decisiones que el usuario tome en cada iteración. Avanza de forma incremental (Fase por Fase) y valida con el usuario antes de pasar al siguiente bloque grande.

---

## 1. Contexto y Objetivo del Proyecto

* **Nombre del Proyecto:** HabitFlow Mobile
* **Propósito:** Aplicación móvil personal de seguimiento de hábitos diarios, cálculo de rachas y analítica visual semanal, inspirada en el prototipo web SaaS *HabitFlow*.
* **Plataforma Objetivo:** Android (uso personal mediante instalación directa de `.apk` / USB debugging, sin publicación en Google Play Store).
* **Presupuesto de Infraestructura:** **$0 USD** (100% basado en la capa gratuita de Supabase y herramientas Open Source).

---

## 2. Stack Tecnológico Propuesto (Flexible)

* **Framework UI:** Flutter (Dart 3.x)
* **Backend & Base de Datos:** Supabase (PostgreSQL + GoTrue Auth + Row Level Security)
* **Paquetes sugeridos en `pubspec.yaml`:**
  * `supabase_flutter`: Conexión con base de datos y autenticación.
  * `flutter_riverpod` *(o `provider` / `bloc`, adaptable según preferencia en el momento)*: Gestión de estado reactivo.
  * `fl_chart`: Renderizado de gráficos interactivos (progreso diario y comparativa de rachas).
  * `intl`: Formateo de fechas en español (`es_ES` / `es_MX`).
  * `google_fonts`: Tipografía `Inter` para conservar la estética moderna del prototipo.
  * `lucide_icons` (o iconos Material 3): Iconografía limpia estilo SaaS.
  * `confetti` *(opcional)*: Efecto de celebración al completar el $100\%$ de los hábitos del día.
  * `flutter_dotenv` *(opcional)*: Manejo seguro de credenciales de Supabase (`SUPABASE_URL` y `SUPABASE_ANON_KEY`).

---

## 3. Diseño de Base de Datos y Seguridad (Supabase SQL)

El sistema requiere únicamente dos tablas en el esquema `public` vinculadas a `auth.users`.

### 3.1 Script SQL Base

```sql
-- 1. Tabla de Hábitos
create table if not exists public.habits (
  id uuid default gen_random_uuid() primary key,
  user_id uuid references auth.users(id) on delete cascade not null,
  name text not null,
  category text not null default 'Salud',
  icon text not null default '💧',
  color text not null default 'indigo',
  created_at timestamp with time zone default timezone('utc'::text, now()) not null
);

-- 2. Tabla de Registros Diarios (Check-ins)
create table if not exists public.habit_logs (
  id uuid default gen_random_uuid() primary key,
  habit_id uuid references public.habits(id) on delete cascade not null,
  user_id uuid references auth.users(id) on delete cascade not null,
  completed_date date not null,
  created_at timestamp with time zone default timezone('utc'::text, now()) not null,
  unique(habit_id, completed_date)
);

-- 3. Índices para consultas rápidas por rango de fechas
create index if not exists idx_habit_logs_user_date 
  on public.habit_logs(user_id, completed_date);

-- 4. Seguridad a Nivel de Fila (RLS)
alter table public.habits enable row level security;
alter table public.habit_logs enable row level security;

create policy "Acceso total a hábitos propios"
  on public.habits for all
  using (auth.uid() = user_id)
  with check (auth.uid() = user_id);

create policy "Acceso total a registros propios"
  on public.habit_logs for all
  using (auth.uid() = user_id)
  with check (auth.uid() = user_id);
```

---

## 4. Estructura de Carpetas Sugerida

Estructura modular orientada a características (*Feature-first*), fácil de escalar o simplificar durante el desarrollo:

```text
lib/
├── main.dart
├── core/
│   ├── config/          # Inicialización de Supabase y variables de entorno
│   ├── theme/           # Tema Claro/Oscuro (Paleta Slate + Indigo)
│   └── utils/           # Helpers de fechas (Lunes-Domingo) y cálculo de rachas
├── models/
│   ├── habit_model.dart
│   └── habit_log_model.dart
├── services/
│   └── supabase_service.dart  # Operaciones CRUD hacia Supabase
└── features/
    ├── auth/
    │   └── auth_screen.dart   # Login / Registro con Email y Password
    └── dashboard/
        ├── dashboard_screen.dart
        └── widgets/
            ├── kpi_grid_widget.dart         # 4 tarjetas de resumen
            ├── week_navigator_widget.dart   # Selector de semana y filtro de categorías
            ├── habit_matrix_widget.dart     # Lista/Matriz semanal de check-ins
            ├── charts_section_widget.dart   # Gráficos con fl_chart
            └── habit_form_sheet.dart        # BottomSheet para Crear/Editar hábito
```

---

## 5. Especificación Funcional de Módulos (Basado en el Prototipo)

### 5.1 Autenticación y Sesión
* Pantalla limpia de inicio de sesión y creación de cuenta mediante correo y contraseña.
* Persistencia automática de sesión (`supabase_flutter` guarda el token localmente en el dispositivo).
* Botón para cerrar sesión en la barra superior.

### 5.2 Tarjetas KPI de Resumen (Grid $2 \times 2$ en móvil)
1. **Hábitos Activos:** Total de hábitos creados y conteo de categorías únicas.
2. **Cumplimiento de Hoy:** Porcentaje del día actual ($\frac{\text{completados hoy}}{\text{total hábitos}} \times 100$) con barra de progreso lineal.
3. **Mejor Racha Activa:** Número máximo de días consecutivos vigentes y nombre del hábito líder.
4. **Total en la Semana:** Cantidad de objetivos cumplidos en la semana seleccionada y porcentaje de efectividad semanal ($\frac{\text{completados semana}}{\text{total hábitos} \times 7} \times 100$).

### 5.3 Lógica de Cálculo de Rachas (`StreakCalculator`)
Para cada hábito, a partir de su conjunto de fechas completadas (`Set<String>` en formato `YYYY-MM-DD`):
* **Racha Actual (`currentStreak`):**
  * Si el hábito está completado **hoy**, se cuenta hacia atrás día por día desde hoy mientras existan registros consecutivos.
  * Si no está completado hoy pero sí **ayer**, se cuenta hacia atrás desde ayer (la racha sigue viva hasta que termine el día de hoy).
  * En caso contrario, la racha actual es $0$.
* **Mejor Racha Histórica (`bestStreak`):**
  * Se ordenan todas las fechas históricas ascendentemente y se calcula la secuencia máxima de días consecutivos ($\Delta = 1\text{ día}$).

### 5.4 Matriz / Tarjetas de Seguimiento Semanal (Adaptada a Pantalla Móvil)
> *Nota de UX Móvil para el Agente:* En pantallas móviles verticales, una tabla de $11$ columnas puede requerir demasiado scroll horizontal. Se propone diseñar cada hábito como una **Tarjeta Compacta** que muestre:
* Cabecera de la tarjeta: Icono emoji, nombre del hábito, categoría, insignia de racha actual (`🔥 Xd`) y menú de editar/eliminar.
* Fila interactiva de $7$ botones circulares/redondeados (`Lun` a `Dom`) correspondientes a la semana activa.
* Actualización optimista (*Optimistic UI*): Al tocar un día, el estado visual cambia de inmediato en pantalla mientras se ejecuta el `insert` o `delete` en Supabase en segundo plano.

### 5.5 Gráficos Interactivos (`fl_chart`)
1. **Progreso Diario de la Semana (`BarChart`):**
   * Eje X: `Lun` a `Dom`.
   * Eje Y: $0\%$ a $100\%$.
   * Colores dinámicos: Barras en verde esmeralda cuando el día alcanza el $100\%$ y en índigo cuando es parcial.
2. **Comparativa de Rachas por Hábito (`BarChart` horizontal o tarjetas comparativas):**
   * Compara visualmente la **Racha Actual** (color ámbar) frente al **Récord Histórico** (color índigo) de cada hábito.

### 5.6 Gestión de Hábitos (BottomSheet Modal)
* Formulario deslizable (`ModalBottomSheet`) para crear o editar un hábito:
  * Campo de texto para el nombre.
  * Selector de Categoría (`Salud`, `Deporte`, `Mente`, `Productividad`, `Finanzas`).
  * Selector de Icono/Emoji (`💧`, `🏋️`, `📚`, `🧘`, `🥗`, `💻`, `🏃`, `💤`, `🎸`, `💰`, `🧠`, `🍵`).
  * Selector de Color de Acento (`indigo`, `emerald`, `amber`, `rose`, `cyan`, `purple`).

---

## 6. Plan de Ejecución Iterativo para el Agente CLI

El agente debe abordar la construcción siguiendo estas fases propuestas, permitiendo ajustes sobre la marcha:

### Fase 1: Inicialización y Configuración Base
1. Crear o verificar el proyecto Flutter (`flutter create habitflow_mobile`).
2. Configurar permisos en `android/app/src/main/AndroidManifest.xml`:
   * Asegurar `<uses-permission android:name="android.permission.INTERNET"/>`.
3. Instalar dependencias base en `pubspec.yaml`.
4. Configurar tema visual Claro/Oscuro y conexión inicial con Supabase.

### Fase 2: Autenticación y Capa de Datos
1. Implementar modelos `Habit` y `HabitLog` con serialización JSON (`fromJson` / `toJson`).
2. Crear el repositorio/servicio de Supabase para obtener hábitos, obtener logs y alternar (toggle) un día completado.
3. Construir la pantalla de Login/Registro y verificar el flujo de sesión.

### Fase 3: Interfaz Principal, KPIs y Matriz Semanal
1. Construir utilidades de fechas (cálculo de Lunes a Domingo según `selectedWeekOffset`) y motor de rachas.
2. Implementar los filtros por categoría y el navegador de semanas.
3. Implementar las 4 tarjetas KPI superiores y la lista interactiva de hábitos con sus 7 días de la semana.
4. Añadir el `ModalBottomSheet` para crear, editar y eliminar hábitos.

### Fase 4: Analítica Visual y Pulido UX
1. Integrar `fl_chart` para el gráfico de barras de cumplimiento semanal y la comparativa de rachas.
2. Añadir animaciones suaves al marcar casillas, modo oscuro persistente (`shared_preferences` opcional) y celebración al llegar al $100\%$ del día.

### Fase 5: Compilación de APK para Uso Personal en Android
1. Ejecutar pruebas de compilación y limpieza de warnings (`flutter analyze`).
2. Generar el instalador final optimizado ejecutando:
   ```bash
   flutter build apk --release
   ```
3. Verificar la ruta de salida en `build/app/outputs/flutter-apk/app-release.apk` o instalar directamente en el teléfono conectado vía USB con:
   ```bash
   flutter install
   ```

---

## 7. Notas de Flexibilidad y Posibles Cambios en el Camino

* **Modo Offline / Caché Local (Opcional):** Si durante el uso diario el usuario nota que a veces registra hábitos sin conexión a internet, se puede agregar más adelante una caché local ligera con `shared_preferences` o `isar`/`sqflite` sin rehacer la interfaz.
* **Recordatorios Locales (Opcional):** Si en el futuro se desean notificaciones en el teléfono a cierta hora del día, se puede incorporar `flutter_local_notifications` sin costo alguno de servidor.
* **Adaptación Visual:** Los gráficos o la disposición de las tarjetas pueden simplificarse o reorganizarse en pestañas (`BottomNavigationBar`: *Hoy / Matriz*, *Estadísticas*, *Ajustes*) si se siente más cómodo en la pantalla del teléfono.