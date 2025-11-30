//
//  NewPostView.swift
//  Motra
//
//  Created by Jaeeun Byun on 11/28/25.
//

import SwiftUI

struct NewPostView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var viewModel = NewPostViewModel()
    
    @State private var content = ""
    @State private var selectedVisibility: PostVisibility = .public
    @State private var showExercisePicker = false
    @State private var selectedExercise: Exercise?
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // 내용 입력
                contentSection
                
                Divider()
                
                // 운동 기록 연결
                exerciseSection
                
                Divider()
                
                // 공개 범위 설정
                visibilitySection
                
                Spacer()
            }
            .navigationTitle("새 글 작성")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("취소") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("게시") {
                        Task {
                            await createPost()
                        }
                    }
                    .disabled(content.isEmpty)
                    .fontWeight(.semibold)
                }
            }
            .sheet(isPresented: $showExercisePicker) {
                ExercisePickerView(selectedExercise: $selectedExercise)
            }
            .overlay {
                if viewModel.isLoading {
                    ProgressView()
                        .scaleEffect(1.5)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .background(Color.black.opacity(0.2))
                }
            }
        }
    }
    
    // MARK: - 내용 입력 섹션
    private var contentSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            TextEditor(text: $content)
                .frame(minHeight: 150)
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
            
            Text("\(content.count)/500")
                .font(.caption)
                .foregroundStyle(.secondary)
                .padding(.horizontal)
                .padding(.bottom, 8)
        }
    }
    
    // MARK: - 운동 기록 연결 섹션
    private var exerciseSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "figure.run")
                    .foregroundStyle(.blue)
                Text("운동 기록 연결")
                    .font(.subheadline)
                    .fontWeight(.medium)
                
                Spacer()
                
                Button {
                    showExercisePicker = true
                } label: {
                    Text(selectedExercise == nil ? "선택하기" : "변경")
                        .font(.subheadline)
                        .foregroundStyle(.blue)
                }
            }
            
            if let exercise = selectedExercise {
                selectedExerciseCard(exercise)
            }
        }
        .padding()
    }
    
    // MARK: - 선택된 운동 카드
    private func selectedExerciseCard(_ exercise: Exercise) -> some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(exercise.exerciseType)
                    .font(.subheadline)
                    .fontWeight(.medium)
                
                HStack(spacing: 12) {
                    Label(exercise.distanceInKm + " km", systemImage: "arrow.left.arrow.right")
                    Label(exercise.durationFormatted, systemImage: "clock")
                }
                .font(.caption)
                .foregroundStyle(.secondary)
            }
            
            Spacer()
            
            Button {
                selectedExercise = nil
            } label: {
                Image(systemName: "xmark.circle.fill")
                    .foregroundStyle(.secondary)
            }
        }
        .padding()
        .background(Color(.secondarySystemGroupedBackground))
        .clipShape(RoundedRectangle(cornerRadius: 10))
    }
    
    // MARK: - 공개 범위 섹션
    private var visibilitySection: some View {
        HStack {
            Image(systemName: selectedVisibility.icon)
                .foregroundStyle(.blue)
            
            Text("공개 범위")
                .font(.subheadline)
                .fontWeight(.medium)
            
            Spacer()
            
            Picker("", selection: $selectedVisibility) {
                ForEach(PostVisibility.allCases, id: \.self) { visibility in
                    Text(visibility.rawValue).tag(visibility)
                }
            }
            .pickerStyle(.menu)
        }
        .padding()
    }
    
    // MARK: - Create Post
    private func createPost() async {
        await viewModel.createPost(
            content: content,
            exercise: selectedExercise,
            visibility: selectedVisibility
        )
        
        if viewModel.errorMessage == nil {
            dismiss()
        }
    }
}

// MARK: - NewPostViewModel
@MainActor
class NewPostViewModel: ObservableObject {
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    private let postRepository: PostRepository
    private let exerciseRepository: ExerciseRepository
    
    init(
        postRepository: PostRepository = LocalPostRepository(),
        exerciseRepository: ExerciseRepository = CoreDataExerciseRepository()
    ) {
        self.postRepository = postRepository
        self.exerciseRepository = exerciseRepository
    }
    
    func createPost(content: String, exercise: Exercise?, visibility: PostVisibility) async {
        isLoading = true
        errorMessage = nil
        
        // 운동 요약 생성
        var exerciseSummary: ExerciseSummary? = nil
        if let exercise = exercise {
            exerciseSummary = ExerciseSummary(from: exercise)
        }
        
        // 실제 티어 계산
        let currentTier = await calculateCurrentTier()
        let tierData = TierData(
            grade: currentTier.grade.rawValue,
            division: currentTier.division.rawValue
        )
        
        let post = Post(
            authorNickname: "나",  // TODO: 실제 유저 정보 사용
            authorUsername: "me",
            authorTier: tierData,
            exerciseId: exercise?.id,
            content: content,
            visibility: visibility,
            exerciseSummary: exerciseSummary
        )
        
        do {
            _ = try await postRepository.createPost(post)
        } catch {
            errorMessage = "게시물 작성에 실패했습니다."
        }
        
        isLoading = false
    }
    
    // 현재 티어 계산
    private func calculateCurrentTier() async -> Tier {
        do {
            let exercises = try await exerciseRepository.fetchExercises()
            let totalDistance = exercises.reduce(0) { $0 + $1.distance }
            return TierCalculator.calculateTier(totalDistanceInMeters: totalDistance)
        } catch {
            // 에러 시 기본 티어 반환
            return Tier(grade: .bronze, division: .four)
        }
    }
}

// MARK: - 운동 기록 선택 뷰
struct ExercisePickerView: View {
    @Environment(\.dismiss) private var dismiss
    @Binding var selectedExercise: Exercise?
    @StateObject private var viewModel = ExercisePickerViewModel()
    
    var body: some View {
        NavigationStack {
            Group {
                if viewModel.isLoading {
                    ProgressView()
                } else if viewModel.exercises.isEmpty {
                    emptyState
                } else {
                    exerciseList
                }
            }
            .navigationTitle("운동 기록 선택")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("취소") { dismiss() }
                }
            }
        }
    }
    
    private var emptyState: some View {
        VStack(spacing: 12) {
            Image(systemName: "figure.run.circle")
                .font(.system(size: 50))
                .foregroundStyle(.gray)
            
            Text("운동 기록이 없어요")
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
    }
    
    private var exerciseList: some View {
        List(viewModel.exercises) { exercise in
            Button {
                selectedExercise = exercise
                dismiss()
            } label: {
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        HStack {
                            Image(systemName: getIcon(for: exercise.exerciseType))
                                .foregroundStyle(.blue)
                            Text(exercise.exerciseType)
                                .fontWeight(.medium)
                        }
                        
                        Text(formatDate(exercise.startDate))
                            .font(.caption)
                            .foregroundStyle(.secondary)
                        
                        HStack(spacing: 12) {
                            Text(exercise.distanceInKm + " km")
                            Text(exercise.durationFormatted)
                        }
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    }
                    
                    Spacer()
                    
                    if selectedExercise?.id == exercise.id {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundStyle(.blue)
                    }
                }
            }
            .buttonStyle(.plain)
        }
    }
    
    private func getIcon(for type: String) -> String {
        switch type {
        case "러닝": return "figure.run"
        case "사이클": return "figure.outdoor.cycle"
        case "워킹": return "figure.walk"
        case "등산": return "figure.hiking"
        default: return "figure.run"
        }
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "M월 d일 HH:mm"
        return formatter.string(from: date)
    }
}

// MARK: - ExercisePickerViewModel
@MainActor
class ExercisePickerViewModel: ObservableObject {
    @Published var exercises: [Exercise] = []
    @Published var isLoading = false
    
    private let exerciseRepository: ExerciseRepository
    
    init(exerciseRepository: ExerciseRepository = CoreDataExerciseRepository()) {
        self.exerciseRepository = exerciseRepository
        
        Task {
            await loadExercises()
        }
    }
    
    func loadExercises() async {
        isLoading = true
        
        do {
            exercises = try await exerciseRepository.fetchExercises()
        } catch {
            exercises = []
        }
        
        isLoading = false
    }
}

#Preview {
    NewPostView()
}
