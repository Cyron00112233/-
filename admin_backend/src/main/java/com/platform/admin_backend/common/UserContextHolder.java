package com.platform.admin_backend.common;

import com.platform.admin_backend.enums.RoleEnum;

public class UserContextHolder {
    private static final ThreadLocal<UserContext> CONTEXT = new ThreadLocal<>();

    public static void set(UserContext ctx) { CONTEXT.set(ctx); }
    public static UserContext get() { return CONTEXT.get(); }
    public static Long getUserId() { UserContext ctx = get(); return ctx != null ? ctx.getUserId() : null; }
    public static RoleEnum getRole() { UserContext ctx = get(); return ctx != null ? ctx.getRole() : null; }
    public static void clear() { CONTEXT.remove(); }

    public static class UserContext {
        private Long userId;
        private String username;
        private RoleEnum role;

        public UserContext(Long userId, String username, RoleEnum role) {
            this.userId = userId; this.username = username; this.role = role;
        }
        public Long getUserId() { return userId; }
        public void setUserId(Long userId) { this.userId = userId; }
        public String getUsername() { return username; }
        public void setUsername(String username) { this.username = username; }
        public RoleEnum getRole() { return role; }
        public void setRole(RoleEnum role) { this.role = role; }
    }
}