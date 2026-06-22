//
//  StatsView.swift
//  GameVault
//
//  Created by Juanjo on 20/06/2026.
//

import SwiftUI
import SwiftData
import Charts


struct StatsView: View {
    @Query private var games: [Game]
    @State private var vm = StatsViewModel()
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                summarySection
                statusChart
                platformChart
                if !vm.completedByMonth.isEmpty {
                    completedByMonthChart
                }
                topGamesList
            }
            .padding()
        }
        .navigationTitle("Estadísticas")
        .task {
            withAnimation(.easeOut(duration: 0.6)) {
                vm.update(with: games)
            }
        }
        .onChange(of: games) { _, newGames in
            vm.update(with: newGames)
        }
    }
    
    private var summarySection: some View {
        GlassEffectContainer(spacing: 12) {
            HStack(spacing: 12) {
                statCard(title: "Total", value: "\(vm.totalGames)", icon: "gamecontroller.fill")
                statCard(title: "Horas", value: vm.totalHoursPlayed.formatted(), icon: "clock.fill")
                statCard(title: "Rating", value: vm.averageRating.map { String(format: "%.1f", $0) } ?? "—", icon: "star.fill")
            }
        }
    }
    
    
    @ViewBuilder
    private func statCard(title: String, value: String, icon: String) -> some View {
        VStack(spacing: 4) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundStyle(.tint)
                .symbolEffect(.bounce, value: value)
            Text(value).font(.title2).bold()
            Text(title).font(.caption).foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .glassEffect(in: .rect(cornerRadius: 12))
    }
    
    private var statusChart: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Por estado").font(.headline)
            Chart(vm.gamesByStatus, id: \.status) { item in
                BarMark(
                    x: .value("Cantidad", item.count),
                    y: .value("Estado", item.status.displayName)
                )
                .foregroundStyle(by: .value("Estado", item.status.displayName))
                .annotation(position: .trailing) {
                    Text("\(item.count)").font(.caption).foregroundStyle(.secondary)
                }
            }
            .chartLegend(.hidden)
            .frame(height: CGFloat(vm.gamesByStatus.count * 40 + 20))
        }
    }
    
    private var platformChart: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Por plataforma").font(.headline)
            Chart(vm.hoursByPlatform, id: \.platform) { item in
                BarMark(
                    x: .value("Horas", item.hours),
                    y: .value("Plataforma", item.platform.displayName)
                )
                .foregroundStyle(by: .value("Plataforma", item.platform.displayName))
                .annotation(position: .trailing) {
                    Text("\(item.hours.formatted())h").font(.caption).foregroundStyle(.secondary)
                }
            }
            .chartLegend(.hidden)
            .frame(height: CGFloat(vm.hoursByPlatform.count * 40 + 20))
        }
    }
    
    private var completedByMonthChart: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Completados por mes").font(.headline)
            Chart(vm.completedByMonth, id: \.month) { item in
                LineMark(
                    x: .value("Mes", item.month, unit: .month),
                    y: .value("Completados", item.count)
                )
                PointMark(
                    x: .value("Mes", item.month, unit: .month),
                    y: .value("Completados", item.count)
                )
            }
            .frame(height: 220)
        }
    }
    
    private var topGamesList: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Top 5 por horas").font(.headline)
            ForEach(vm.topGamesByHours) { game in
                HStack {
                    Text(game.title).fontWeight(.medium)
                    Spacer()
                    Text("\(game.hoursPlayed.formatted())h")
                        .foregroundStyle(.secondary)
                }
                .padding(.vertical, 4)
                Divider()
            }
        }
    }
    
    
}

#Preview {
    NavigationStack {
        StatsView()
            .modelContainer(for: Game.self)
    }
}
